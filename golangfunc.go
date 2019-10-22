package main

import (
	"fmt"
	"net/http"
	"reflect"
	"sort"
	"sync"
	"time"
)

// base
func add(a int, b int) int {
	return a + b
}

func subtract(a, b int) int {
	return a - b
}

func multiply(a, b int) int {
	return a * b
}

func divide(a, b int) int {
	return a / b
}

// in and out
func withoutInAndOut() {
	fmt.Println("input or return is not necessary")
}

func addButNotReturn(a int, b int) {
	sum := a + b
	fmt.Println(sum)
}

func fibonacci() []int {
	var fibTable []int
	fibTable = append(fibTable, []int{1, 1}...)
	a, b := 1, 1
	for i := 0; i < 8; i++ {
		fibTable = append(fibTable, a+b)
		a, b = b, a+b
	}
	return fibTable
}

// higher-order functions
func opreate(a, b int, op func(int, int) int) int {
	return op(a, b)
}

func operatorFactory(operation string) func(int, int) int {
	switch operation {
	case "+":
		return add
	case "-":
		return subtract
	case "*":
		return multiply
	case "/":
		return divide
	}
	return nil
}

func addOpreateDelay(a, b int) func() int {
	return func() int {
		return add(a, b)
	}
}

// user-defined function type
type operatorFunc func(int, int) int

func opreateB(a, b int, op operatorFunc) int {
	return op(a, b)
}

func switchType(f interface{}) {
	switch f.(type) {
	case func(int, int) int:
		fmt.Println("func(int,int) int")
	case operatorFunc:
		fmt.Println("operatorFunc")
	default:
		fmt.Println("unknow")
	}
}

// Functional interface
type operator interface {
	operate(int, int) int
}

func (of operatorFunc) operate(a, b int) int {
	return of(a, b)
}

func operateC(a, b int, o operator) int {
	return o.operate(a, b)
}

// http
func sayhello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "hello, now:", time.Now().String())
}

// closure
func fib() func() int {
	a, b := 0, 1
	return func() int {
		a, b = b, a+b
		return a
	}
}

func autoIncrement() func() (int, int) {
	a, sum := 0, 0
	return func() (int, int) {
		a, sum = a+1, a+sum
		return a, sum
	}
}

func timeCost() func() string {
	start := time.Now()
	return func() string {
		return time.Now().Sub(start).String()
	}
}

func doNotUseActually(stopch <-chan int) func() int {
	a, b := 0, 1
	go func(stop <-chan int) {
		for {
			select {
			case <-stop:
				return
			default:
				a, b = b, a+b
			}
			time.Sleep(time.Second)
		}
	}(stopch)
	return func() int {
		return a
	}
}

func main() {
	{
		a, b := 1, 2
		sum := add(a, b)
		fmt.Println(sum)
	}

	{
		withoutInAndOut()
		addButNotReturn(1, 2)
		fmt.Println(fibonacci())
	}

	{
		fmt.Println(opreate(1, 2, multiply))
		fmt.Println(opreate(1, 2, operatorFunc(multiply)))
		var mul operatorFunc = func(a, b int) int {
			return a * b
		}
		fmt.Println(opreateB(1, 2, mul))

		multiplyType := reflect.TypeOf(multiply)
		fmt.Println(multiplyType, ",", multiplyType.Kind())
		mulType := reflect.TypeOf(mul)
		fmt.Println(mulType, ",", mulType.Kind())

		switchType(multiply)
		switchType(mul)

		var mulOperator operatorFunc = multiply
		fmt.Println(mulOperator.operate(1, 2))
		fmt.Println(operatorFunc(multiply).operate(1, 2))
		fmt.Println(operateC(1, 2, mulOperator))
		//fmt.Println(multiply.oerate(1,2))
	}

	{
		divideFunc := operatorFactory("/")
		fmt.Println(opreate(2, 1, divideFunc))
	}

	{
		mod := func(a, b int) int {
			return a % b
		}
		fmt.Println(opreate(7, 4, mod))
		fmt.Println(opreate(7, 4, func(a, b int) int {
			return a % b
		}))
	}

	{
		var wg sync.WaitGroup
		msgCh := make(chan string, 1)

		defer func(ch chan string) {
			close(ch)
		}(msgCh)

		wg.Add(1)
		go func(in <-chan string) {
			for {
				select {
				case msg, ok := <-in:
					if ok {
						fmt.Println("other, msg:", msg)
					}
					wg.Done()
					return
				default:
					fmt.Println("other, now:", time.Now().Unix())
				}
				time.Sleep(500 * time.Millisecond)
			}
		}(msgCh)
		time.Sleep(1 * time.Second)
		fmt.Println("main, now:", time.Now().Unix())
		msgCh <- "print this message received from main goroutine"
		wg.Wait()

		ints := []int{1, 2, 3, 4, 5, 6}
		sort.Slice(ints, func(i, j int) bool {
			return ints[i] > ints[j]
		})
		fmt.Println(ints)
	}

	{
		sum := addOpreateDelay(1, 2)
		fmt.Println("1st call:", sum())
		fmt.Println("2nd call:", sum())
	}

	{
		// s := &http.Server{
		// 	Addr: "127.0.0.1:8080",
		// }
		// http.HandleFunc("/hello", sayhello)
		// s.ListenAndServe()
	}

	{
		f := fib()
		fmt.Println(f(), f(), f(), f(), f())
	}

	{
		tc := timeCost()
		fmt.Println(tc())
		time.Sleep(time.Second)
		fmt.Println(tc())
		time.Sleep(time.Second)
		fmt.Println(tc())
	}

	{
		var out int = 10
		var in1 int = 11
		var in2 int = 11
		for i := 0; i < out; i++ {
			var in1 int
			fmt.Print(in1, ", ")
			in1 = i
			in2 = i
			fmt.Println(in1, in2)
		}
		fmt.Println(in1, in2)
	}

	{
		// {
		// 	inner := "in"
		// 	fmt.Println(inner)
		// }
		// fmt.Println(inner)
	}

	{
		stop := make(chan int, 1)
		f := doNotUseActually(stop)
		fmt.Println(f())
		time.Sleep(5 * time.Second)
		fmt.Println(f())
		stop <- 1
		close(stop)
	}
}

// output:
//
