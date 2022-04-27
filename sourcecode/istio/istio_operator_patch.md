# istio operator patch 的实现

[patch](https://github.com/istio/istio/tree/master/operator/pkg/patch)
[tpath](https://github.com/istio/istio/tree/master/operator/pkg/tpath)

* 容器 `map[any]any`
* 针对 list 对象的语法设计: `[index], [field:value]`
* **patch 目标的数据结构设计** (最精妙的地方)

简略的模拟：

``` golang
package main

import (
    "fmt"
    "log"
    "reflect"
    "strconv"
    "strings"

    "gopkg.in/yaml.v2"
)

type patch struct {
    path  string
    value any
}

type pathContext struct {
    parent *pathContext
    key    any
    node   any
}

func getPath(path string) []string {
    ps := strings.Split(path, ".")
    var ret []string
    for _, s := range ps {
        nBracket := strings.IndexRune(s, '[')
        if nBracket >= 0 {
            ret = append(ret, s[nBracket+1:len(s)-1])
        } else {
            ret = append(ret, s)
        }
    }
    return ret
}

func nPath(path string) (int, bool) {
    i, err := strconv.Atoi(path)
    return i, err == nil
}

func kvPath(path string) (string, string, bool) {
    idx := strings.Index(path, ":")
    if idx == -1 {
        return "", "", false
    }
    return path[:idx], path[idx+1:], true
}

func getPathContext(root *pathContext, ps []string) *pathContext {
    if len(ps) == 0 {
        return root
    }
    if root.node == nil {
        _, np := nPath(ps[0])
        _, _, nkv := kvPath(ps[0])
        if np || nkv {
            root.node = []any{}
        } else {
            root.node = make(map[any]any)
        }
    }

    // list
    idx, np := nPath(ps[0])
    if np {
        l := root.node.([]any)
        var foundNode any
        if idx >= len(l) {
            idx = len(l)
            foundNode = make(map[any]any)
        } else {
            foundNode = l[idx]
        }
        nn := &pathContext{
            parent: root,
            key:    idx,
            node:   foundNode,
        }
        return getPathContext(nn, ps[1:])
    }

    // list
    k, v, nkv := kvPath(ps[0])
    if nkv {
        lm := root.node.([]any)
        var foundNode any
        var idx int = -2
        for i, m := range lm {
            if m.(map[any]any)[k] == v {
                foundNode = m
                idx = i
            }
        }
        if foundNode == nil {
            foundNode = map[any]any{k: v}
            idx = len(lm)
        }
        nn := &pathContext{
            parent: root,
            key:    idx,
            node:   foundNode,
        }
        return getPathContext(nn, ps[1:])
    }

    // map
    m := root.node.(map[any]any)
    var foundNode any
    var mk string
    for tk, tv := range m {
        if tk.(string) == ps[0] {
            mk = tk.(string)
            foundNode = tv
        }
    }
    if foundNode == nil {
        mk = ps[0]
        foundNode = make(map[any]any)
    }
    nn := &pathContext{
        parent: root,
        key:    mk,
        node:   foundNode,
    }
    return getPathContext(nn, ps[1:])
}

func setValue(pc *pathContext, value any) {
    if pc.parent == nil {
        return
    }

    newPC := pc.parent
    if newPC.node == nil {
        return
    }

    typ := reflect.TypeOf(newPC.node)
    switch typ.Kind() {
    case reflect.Map:
        m := newPC.node.(map[any]any)
        m[pc.key] = value
    case reflect.Slice:
        l := newPC.node.([]any)
        if len(l) <= pc.key.(int) {
            l = append(l, value)
        } else {
            l[pc.key.(int)] = value
        }
        newPC.node = l
    }
    setValue(newPC, newPC.node)
}

func main() {
    bo := make(map[any]any)
    err := yaml.Unmarshal([]byte(baseYaml), bo)
    if err != nil {
        log.Fatal(err)
    }
    printObj(bo)
    p := patch{
        path:  "base.structArray.[key:asdf].value",
        value: "afqwe",
    }
    ps := getPath(p.path)
    fmt.Println(ps)
    pc := getPathContext(&pathContext{node: bo}, ps)
    setValue(pc, p.value)
    printObj(bo)
}

func printObj(obj any) {
    bs, _ := yaml.Marshal(obj)
    fmt.Println(string(bs))
}

var (
    baseYaml = `base:
  struct:
    fieldA: a
    fieldB: b
  string: str
  strArray:
  - strA
  - strB
  structArray:
  - key: ak
    value: av
  - key: bk
    value: bv`
)

```
