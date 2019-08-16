# some of golang

* golang `var name = XXXXX()` 和 `:=` 形式的类型推断带来的好处?

   类型推断是在编译时完成的，并不会影响程序执行时的效率，但是在编写过程中一定程度上能够体会到动态类型语言的便利。与此同时，类型推断会使得代码重构更加方便，增加了程序的灵活性；因为其静态类型语言，一旦变量初始化是确定类型，后续都不可以改变，维护性更高。

* goalang 的重声明发生的条件
  * 在同一个代码块中
  * 使用 `:=` 来完成
  * 必须是在申明多个变量中新旧变量混在一起的情况
  * 与原变量类型要保持一致

* 模块级别私有

  internal 代码包的使用

  ``` file
  src
    project_name
        ├─packageA_name
        │     ├─internal
        │     │     └─internal.go // 此源码文件内的文件非私有程序实体，包外无法访问
        │     └─xxx.go
        └─packageB_name  
  ```

* **短边量声明的不理解处？？？**

  ``` go
  package main

  import (
      "fmt"
  )

  type Foo struct {
      name string
  }

  func Make()(string,error){
      return "foo",nil
  }

  func main(){
      var f Foo = Foo{}
      f.name,err:=Make()  //non-name f.name on left side of :=
      if err != nil{
          fmt.Println(err)
      }else{
          fmt.Printf("v%",f)
      }
  }
  ```

* go 的闭包

  斐波那契闭包实现

  ``` go
  package main

  import "fmt"

  // fibonacci 函数会返回一个返回 int 的函数。
  func fibonacci() func() int {
      before, current := 0, 1
      return func() int {
          before, current = current, before+current
          return current
      }
  }

  func main() {
      f := fibonacci()
      for i := 0; i < 10; i++ {
          fmt.Println(f())
      }
  }
  ```
