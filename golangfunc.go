package main

import (
	"fmt"
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

	}
}

// output:
//
