# golang 函数式编程

> [In programming language design, a first-class citizen (also type, object, entity, or value) in a given programming language is an entity which supports all the operations generally available to other entities. These operations typically include being passed as an argument, returned from a function, modified, and assigned to a variable.](https://en.wikipedia.org/wiki/First-class_citizen)  
>  
> [Go supports first class functions, higher-order functions, user-defined function types, function literals, closures, and multiple return values.](https://golang.org/doc/codewalk/functions/)

## 基本语法

通常函数是一个 **code block**，对输入进行处理产生输出，下例中实现了一个加法运算函数，并对其进行了调用

``` golang
// 申明一个函数
func add(a int, b int) int {
    return a + b
}

// 使用一个函数
func main() {
    a, b := 1, 2
    sum := add(a, b)
    fmt.Println(sum)
}
// output:
// 3
```

当然，函数也可以没有“输入”、“输出”，类似上文中 `main` 函数，也可以只拥有输入或输出, 既 **optional**，见下例。（为了准确，后文中将使用返回值来作为函数狭义“输出”的表达，相应的，函数狭义的“输入”用入参来表达。）

``` golang
func withoutInAndOut() {
    fmt.Println("input or return is not necessary")
}

func addButNotReturn(a, b int) {
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

func main() {
    withoutInAndOut()
    addButNotReturn(1, 2)
    fmt.Println(fibonacci())
}
// output:
// input or return is not necessary
// 3
// [1 1 2 3 5 8 13 21 34 55]
```

此外，golang 函数支持的多返回值，命名返回，下划线接收未使用返回值不再做介绍。

## 高级特性 ———— First-class function

### 函数对象 ———— higher-order function

高阶函数至少满足一个以下条件：

1. 接收至少一个函数作为入参
2. 返回一个函数作为函数执行的结果

#### 函数作为入参 ———— passing functions as arguments to other functions

从服务的角度来看，前文提供了加法运算，使用时可能想用乘法，但是服务没有提供。这时，可以服务可以抽象一层，所有的运算对外统一到一个入口，调用者提供运算的参数和规则，这个运算的规则就是函数。下例中，实现了一个乘法运算的函数，并将其和乘法运算的因子一起提供给了作为运算入口的 `opreate` 函数。

``` golang
func multiply(a, b int) int {
    return a * b
}

func opreate(a, b int, op func(int, int) int) int {
    return op(a, b)
}

func main() {
    fmt.Println(opreate(1, 2, multiply))
}
// output:
// 2
```

函数作为参数不仅仅在运算参数执行方式自定义上提供了便利，对于原函数的功能拓展、执行与否等等都提供了可能性。

#### 匿名函数 ———— anonymous functions

有时候，自定义的函数是临时的，并不需要在别的地方被使用或者只是为了这一次的执行，那么可以把函数定义一个函数体内部。如下示例代码在内部定义了一个取余的函数，并且将其赋值给了一个名为 `mod` 变量，仅限同一代码块中 `opreate` 函数可以直接使用这个 `mod` 函数，并且 `mod` 函数在该代码块中不同的地方被调用。如果，为了临时执行一次某个任务，可以想第三条 `Println` 语句中那样使用匿名函数的方式。

``` golang
func main() {
    mod := func(a, b int) int {
        return a % b
    }
    fmt.Println(opreate(7, 4, mod))
    fmt.Println(mod(7,4))
    fmt.Println(opreate(7, 4, func(a, b int) int {
        return a % b
    }))
}
// output:
// 3
// 3
// 3
```

匿名函数在常被用在新 goroutine 的创建、`defer` 语句等等，golang sort 包的 `slice interface{}, less func(i, j int) bool` 也是一个例子。

``` golang
func main() {
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
// output:
// other, waiting and now: 1570697767
// other, waiting and now: 1570697768
// main,  1570697768
// other, waiting and now: 1570697768
// print this message received from main goroutine
// [6 5 4 3 2 1]
```

#### 函数作为返回值 ———— returning functions as the values from other functions

函数作为参数可以使用，自然也可以作为结果被返回，比如如下只是为了举例的例子。

``` golang
func subtract(a, b int) int {
    return a - b
}

func multiply(a, b int) int {
    return a * b
}

func divide(a, b int) int {
    return a / b
}

func opertorFactory(operation string) func(int, int) int {
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

func main() {
    subtract := opertorFactory("-")
    divide := opertorFactory("/")
    fmt.Println(opreate(2, 1, subtract))
    fmt.Println(opreate(2, 1, divide))
}
// output:
// 1
// 2
```

作为返回值的函数，一个重要的是作用是能够携带一些数据，在合适的时候被调用，比如下面的例子，`addOpreateDelay` 函数返回了 `sum` 函数可以延迟执行，在需要的时候调用 `sum` 就能得到想要的结果

``` golang

func addOpreateDelay(a, b int) func() int {
    return func() int {
        return add(a, b)
    }
}

func main(){
    sum := addOpreateDelay(1, 2)
    fmt.Println("1st call:", sum())
    fmt.Println("2nd call:", sum())
}
// output:
// 1st call: 3
// 2nd call: 3
```

### 自定义函数类型

在 golang 中作为 first class citizen 的函数既可以做参数，也可以做返回值，还可以被赋值给变量，自然而然的像是其他基本类型一样，我们可以通过 `type` 关键字给一类函数起个名字———— `User-defined function types`。 函数的类型签名描述了其参数和返回值的类型，拥有相同类型及数目的参数和返回值的函数可以被认为是该函数类型。

下面的例子中，首先自定义了 `operatorFunc` 类型，然后新的计算函数 `opreateB` 接收的参数 `op` 可以用自定义的函数类型来声明了（variable declaration）。无论直接传入 `multiply` 还是转型后 `operatorFunc(multiply)` 传入，`opreateB` 都能够正确的执行，这是因为 golang 的 [assignability](https://golang.org/ref/spec#Assignability) 实现了类型自动转换，需要注意的是，`multiply` 可以被自动转型为 `operatorFunc`，但并不是 `operatorFunc`。

``` golang
type operatorFunc func(int,int) int

func opreateB(a, b int, op operatorFunc) int {
    return op(a,b)
}

func switchType(f interface{}){
    switch f.(type) {
    case func(int,int) int:
        fmt.Println("func(int,int) int")
        case operatorFunc :
        fmt.Println("operatorFunc")
        default:
        fmt.Println("unknow")
    }
}

func main() {
    fmt.Println(opreateB(1, 2, multiply))
    fmt.Println(opreateB(1, 2, operatorFunc(multiply)))
    var mul = func(a, b int) int {
        return a * b
    }
    fmt.Println(opreateB(1, 2, mul))

    multiplyType := reflect.TypeOf(multiply)
    fmt.Println(multiplyType, multiplyType.Kind())
    mulType := reflect.TypeOf(mul)
    fmt.Println(mulType, mulType.Kind())

    switchType(multiply)
    switchType(mul)
    }
}
// output:
// 2
// 2
// 2
//
// func(int, int) int func
// main.operatorFunc func
//
// func(int,int) int
// operatorFunc
```

> A value x is assignable to a variable of type T ("x is assignable to T") if one of the following conditions applies:
>
> - x's type is identical to T. （x 就是 T）
> - x's type V and T have identical underlying types and at least one of V or T is not a defined type. （x 的类型和 T 底层类型是一样的，且至少有一个不是自定义类型）
> - T is an interface type and x implements T. （T 是接口，x 实现了 T）
> - x is a bidirectional channel value, T is a channel type, x's type V and T have identical element types, and at least one of V or T is not a defined type. （ x 是**双向通道**，x 的类型和 T 通道类型相同，且至少有一个不是自定义类型）
> - x is the predeclared identifier nil and T is a pointer, function, slice, map, channel, or interface type. （x 的类型初始默认值是 nil，T 是引用类型）
> - x is an untyped constant representable by a value of type T. （ x 是由 T 的一个合法值表示的无类型常量）

#### 函数实现接口

首先看一下 golang 的接口

> Interfaces in Go provide a way to specify the behavior of an object: if something can do this, then it can be used here.

接口定义了一系列的行为、能力等，具备所有这些行为、能力的对象可以被看成是一类对象。当需要某种能力时，申明需要该类接口，然后那些提供了这些能力的对象就都能被拿过来用。一个不恰当的例子，招聘时候罗列的很多条件，不论个体怎样，满足条件的简历就能通过删选进入到后面的流程，说不恰当是因为通过了罗列的条件不一定就能被录取;-)。

通常的，我们遇到是自定义的 `strcut` 或是类似 `int` 这样的基本类型实现了接口，通过自定义函数类型之后，函数也能够用来实现接口。

``` golang
type operator interface{
    operate(int, int) int
}

type operatorFunc func(int, int) int

func (of operatorFunc)operate(a, b int) int{
    return of(a, b)
}

func operateC(a, b int, o operator) int{
    return o.operate(a, b)
}

func main() {
    var mulOperator operatorFunc = multiply
    fmt.Println(mulOperator.operate(1, 2))
    fmt.Println(operatorFunc(multiply).operate(1, 2))
    fmt.Println(operateC(1, 2, mulOperator))
}
// output:
// 2
// 2
// 2
```

上面的例子中，首先定义了 `operator` 接口，只包含了一个 `operate(int, int) int` 方法。然后用前文中自定义的函数类型 `operatorFunc` 实现了这个方法，实现的方式很简单就是调用自己，自然的，也就是实现了 `operator` 接口。 在 `operateC` 函数中，入参 `o` 是一个实现了 `operator` 接口的对象。最后在 `main` 函数中将 `multiply` 转型成 `operatorFunc`，而 `operatorFunc` 类型实现 `operate(int, int) int` 方法自然可以调用，同时作为 `operateC` 的参数。

golang 中有一个很容易就接触到的例子在 `net/http` 包中:

`http.Server` 最主要的两个结构体除了侦听的 `Addr` 之外，就是相应请求的处理器 `Handler` 接口的实现对象了。这里特别注意一下 `Server` 的注释中讲，`zero value` 是一个合法值

``` golang
// A Server defines parameters for running an HTTP server.
// The zero value for Server is a valid configuration.
type Server struct {
    Addr    string  // TCP address to listen on, ":http" if empty
    Handler Handler // handler to invoke, http.DefaultServeMux if nil
    // ...
}

// A Handler responds to an HTTP request.
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

一个 `zero value` server 的例子

``` golang

func sayhello(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w,"hello")
}

```

supports

``` golang
// HandleFunc registers the handler function for the given pattern
// in the DefaultServeMux.
func HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
    DefaultServeMux.HandleFunc(pattern, handler)
}

// HandleFunc registers the handler function for the given pattern.
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
    if handler == nil {
        panic("http: nil handler")
    }
    mux.Handle(pattern, HandlerFunc(handler))
}

// The HandlerFunc type is an adapter to allow the use of
// ordinary functions as HTTP handlers. If f is a function
// with the appropriate signature, HandlerFunc(f) is a
// Handler that calls f.
type HandlerFunc func(ResponseWriter, *Request)

// ServeHTTP calls f(w, r).
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
    f(w, r)
}
```

### 闭包

#### 技术

#### 保存了环境和功能

#### 自由变量，值关联和引用关联

#### 被捕获
