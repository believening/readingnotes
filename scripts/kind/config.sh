#!/bin/bash

cilium_version=1.14.4
metallb_version=0.13.7

init() {
    helm repo add cilium https://helm.cilium.io/ || true
}

create_cluster() {
    create_cluter_with_network $1 $1
}

create_cluter_with_network() {
    cluster_name=$1
    network_name=$2
    KIND_EXPERIMENTAL_DOCKER_NETWORK=${network_name} kind create cluster --config config.yaml --name $cluster_name

    helm install cilium cilium/cilium --version ${cilium_version} \
        --namespace kube-system \
        --set ipam.mode=kubernetes

    kubectl wait --namespace kube-system \
        --for condition=Ready pod \
        --selector app.kubernetes.io/part-of=cilium \
        --timeout 1h

    helm upgrade cilium cilium/cilium --version ${cilium_version} \
        --namespace kube-system \
        --reuse-values \
        --set hubble.relay.enabled=true \
        --set hubble.ui.enabled=true

    # install lb
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v${metallb_version}/config/manifests/metallb-native.yaml

    kubectl wait --namespace metallb-system \
        --for condition=ready pod \
        --selector app=metallb \
        --timeout 1h

    lb_ip_pool=$(docker network inspect ${network_name} |
        jq -r --arg network_name ${network_name} '.[]|select(.Name==$network_name)|.IPAM.Config[0].Subnet' |
        awk -F '/' '{print $1}' |
        # awk -F '.' '{print $1"."$2".255.192/26"}')
        # awk -F '.' '{print $1"."$2".255.192/27"}')
        awk -F '.' '{print $1"."$2".255.224/27"}')

    kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ${cluster_name}
  namespace: metallb-system
spec:
  addresses:
  - ${lb_ip_pool}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF

}

connect_to_cluster() {
    cluster_name=$1
    another_cluster_name=$2
    for ctr in $(kind get nodes --name ${cluster_name}); do
        docker network connect ${another_cluster_name} ${ctr}
    done
}

init
# create_cluster "cluster1"
# create_cluster "cluster2"
# connect_to_cluster "cluster1" "cluster2"
# connect_to_cluster "cluster2" "cluster1"
create_cluter_with_network $1 $2



cilium_cluster_mesh_install() {
    cluster_name=$1
    cluster_id=$2
    helm install cilium cilium/cilium --version ${cilium_version} \
        --namespace kube-system \
        --set ipam.mode=kubernetes \
        --set ipv4NativeRoutingCIDR=10.0.0.0/8 \
        --set cluster.name=${cluster_name} \
        --set cluster.id=${cluster_id}

    kubectl wait --namespace kube-system \
        --for condition=Ready pod \
        --selector app.kubernetes.io/part-of=cilium \
        --timeout 1h

    helm upgrade cilium cilium/cilium --version ${cilium_version} \
        --namespace kube-system \
        --reuse-values \
        --set hubble.relay.enabled=true \
        --set hubble.ui.enabled=true
}

cilium_cluster_mesh_shareCA() {
    ctx_cluster1=$1
    ctx_cluster2=$2
    kubectl --context=$ctx_cluster1 get secret -n kube-system cilium-ca -o yaml |
        kubectl --context $ctx_cluster2 create -f -
}

cilium_cluster_mesh_enable() {
    ctx_cluster1=$1
    ctx_cluster2=$2
    cilium clustermesh enable --context $ctx_cluster1 --service-type LoadBalancer
    cilium clustermesh enable --context $ctx_cluster2 --service-type LoadBalancer
    cilium clustermesh status --context $ctx_cluster1 --wait
    cilium clustermesh status --context $ctx_cluster2 --wait
    cilium clustermesh connect --context $ctx_cluster1 --destination-context $ctx_cluster2
}

cilium_cluster_mesh() {
    cluster1=$1
    cluster2=$2
    cilium_cluster_mesh_install "${cluster1}" "1"
    cilium_cluster_mesh_shareCA "kind-${cluster1}" "kind-${cluster2}"
    cilium_cluster_mesh_install "${cluster2}" "2"
    cilium_cluster_mesh_enable "kind-${cluster1}" "kind-${cluster2}"
}
