+++
author = "Jet He"
date = "2015-10-23T22:45:07+08:00"
description = "Go中interface的动态特性的分析"
keywords = ["Go"]
tags = ["Go"]
title = "golang interface analysis by gdb"
topics = ["Go"]
type = "post"

+++

interface 在go语言中，是非常重要的一环，总有点让人感到很玄乎不定的感觉。官方的lib中有大量使用，似乎面向对象和动态绑定也能跟interface扯上关系。总之，如果能更好的理解interface的机理，就能更好的理解和使用Go了。

interface的较为深层次的探讨在[这篇blog](http://research.swtch.com/interfaces)里面已经有较为详细的介绍。但是缺乏一些实践，本文遍结合此文，使用GDB实际研究一下。

## interface 内部存储
interface的值，其实是两个指针的组合：data 和 tab。data 实际指向值的指针，tab是go runtime的一个struct：

```
// layout of Itab known to compilers
// allocated in non-garbage-collected memory
type itab struct {
    inter  *interfacetype

    _type  *_type

    link   *itab

    bad    int32
    unused int32
    fun    [1]uintptr // variable sized
}
```
在运行时该结构会被runtime库计算出来，保证interface的正常运转。
使用**go build -gcflags "-N -l"**编译便可以是用GDB来debug了。
断点断在最后一行代码，代码在最后列出。
```
(gdb) info locals
b = 200
s = {tab = 0x7ffff7e0f1c0, data = 0xc82000a3b0}
nothing = {_type = 0x4c1360, data = 0xc82000a430}
face = {tab = 0x0, data = 0x0}
any = {_type = 0x4e4a80, data = 0xc82000a3c0}
```
首先看变量*s*，内部有个tab指针和data指针。
```
(gdb) p  *s.tab
$24 = {inter = 0x4dffa0, _type = 0x4e4a80, link = 0x0, bad = 0, unused = 0, fun = {4200784}}
```
结构就是上面的itab的数据结构，其中的interfacetype 和 _type的结构分别为：
```
type interfacetype struct {
    typ  _type

    mhdr []imethod

}
// Needs to be in sync with ../cmd/internal/ld/decodesym.go:/^func.commonsize,
// ../cmd/internal/gc/reflect.go:/^func.dcommontype and
// ../reflect/type.go:/^type.rtype.
type _type struct {
    size       uintptr
    ptrdata    uintptr // size of memory prefix holding all pointers
    hash       uint32
    _unused    uint8
    align      uint8
    fieldalign uint8
    kind       uint8
    alg        *typeAlg

    // gcdata stores the GC type data for the garbage collector.
    // If the KindGCProg bit is set in kind, gcdata is a GC program.
    // Otherwise it is a ptrmask bitmap. See mbitmap.go for details.
    gcdata  *byte
    _string *string
    x       *uncommontype

    ptrto   *_type

    zero    *byte // ptr to the zero value for this type
}
```
分别看下里面的内容：
```
(gdb) p  *s.tab.inter
$26 = {typ = {size = 16, ptrdata = 16, hash = 3958674519, _unused = 0 '\000', align = 8 '\b', fieldalign = 8 '\b', kind = 20 '\024', alg = 0x592770 <runtime.algarray+240>,
    gcdata = 0x537142 "\003\004\005\006\a\b\t\n\r\016\017\020\021\022\025\026\031\032\033\037,568>?Ur\236\237\325\365\377", _string = 0x5161d0, x = 0x4e0018, ptrto = 0x4b6e80,
    zero = 0x539c40 <runtime.zerovalue> ""}, mhdr = {array = 0x4e0000, len = 1, cap = 1}}
(gdb) p  *s.tab._type
$27 = {size = 8, ptrdata = 0, hash = 1148337467, _unused = 0 '\000', align = 8 '\b', fieldalign = 8 '\b', kind = 139 '\213', alg = 0x5926d0 <runtime.algarray+80>,
  gcdata = 0x537140 "\001\002\003\004\005\006\a\b\t\n\r\016\017\020\021\022\025\026\031\032\033\037,568>?Ur\236\237\325\365\377", _string = 0x5161c0, x = 0x4e4ac8, ptrto = 0x4e4d20,
  zero = 0x539c40 <runtime.zerovalue> ""}
(gdb) p  *s.tab.inter.typ._string
$28 = 0x50b930 "main.Stringer"
(gdb) p  *s.tab._type._string
$29 = 0x50b920 "main.Binary"
```
可以清晰的看出，itab的type是interface所包含值的type信息：**main.Binary**，而tab的interface type为该interface的类型信息: **main.Stringer**。
他们的size是不一样的。Binary的size为8个字节，而interface是16个字节。
**想想为啥interface是16个字节的大小？这里可以大胆猜测16个字节是系统内存管理的对齐对齐最小字节数，即libc之前的内存管理里面分配内存都是以16字节作为对齐的，这样也是为了方便内存管理吧。**
要想搞清楚tab里面所有变量的意义，那是不可能的了，在GDB调试过程中，发现中间穿插大量的汇编代码，特别是runtime库实现interface计算过程中。
继续，s的data也是个指针可以直接将其值打印出来：
```
(gdb) p *uint64(s.data)
$22 = 200
```
因为我们事先知道该值类型为64位的uint型。
接着看下any和nothing这两个变量。该两个变量有着不同的类型。
```
(gdb) p nothing
$51 = {_type = 0x4c1360, data = 0xc82000a430}
(gdb) p any
$52 = {_type = 0x4e4a80, data = 0xc82000a3c0}
```
针对interface go的编译器有两种的内存优化策略，就像上面两个变量，他们就不再有itab了，只是type，原因是他们没有方法集。上面文章中说的第二种优化策略，在实际测试中并没有验证出来，即如果interface里面的data值是32位的，则该data字段会直接存该值，不会用指针多一层引用了，即代码中的s32。

通过上面可以看出interface是runtime的产物，是go运行时的对象。这个很像C++中的虚函数表的行为。
从而也可以意识到interface是类型和接口同时兼备的，任何变量都可以赋值给interface，如果该变量是没有接口方法的话，那么interface就是只存其类型信息，否则如果有接口方法，就会多一个itab出来，里面会有其对应的函数列表。
**这样也就很容易理解，interface可以包容任何变量了，因为在运行时，interface变量会记录其所包含值的类型信息。**

## interface使用
关于interface的使用方面，有不少文章做了介绍，比如：[ How to use interfaces in Go](http://jordanorelli.com/post/32665860244/how-to-use-interfaces-in-go)和[Effective Go](https://golang.org/doc/effective_go.html#interfaces)。
从上面部分可以了解到，interface是一种运行时类型，既有函数集还有数据。interface本身定义只能定义方法集，你所要做的就是把这些方法赋予某个Object上面。这样Object就有了这个interface的能力，任意使用这个interface作为参数或者值的地方，Object也就可以畅通无阻了。
interface可以接纳任意类型，因interface内部的type信息是完备的：用type switch 可以获取interface内部value的类型信息，如下所示。
```
type Stringer interface {
    String() string
}

var value interface{} // Value provided by caller.
switch str := value.(type) {
case string:
    return str
case Stringer:
    return str.String()
}
```
interface 更为抽象化的接口，通过interface来定义你的行为方法，行为方法里面会对对象数据产生变化，这个也是需要进行隔离的。跟与C++编码那种面向对象的思想有点出入，看起来不是那么直观。面向对象即先定义对象，和对象的行为。Go里面也是可以定义自己的对象和方法，然后再把这些方法抽象成一个类型：interface，interface就可以使用在函数接口当中，其实此时传递的时候还是你所定义的对象。

总体上感觉interface比面向对象更抽象了一层，需要在更多的实际开发过程中慢慢体会。

附：
```
package main

import (
     "fmt"
     "strconv"
)

type Stringer interface {
    String() string
}

func ToString(any interface{}) string {
    if v, ok := any.(Stringer); ok {
        return v.String()
    }
    switch v := any.(type) {
    case int:
        return strconv.Itoa(v)
    case float32:
        return strconv.FormatFloat(float64(v), 'g', -1, 32)
    }
    return "???"
}

type Binary uint64
type Binary32 uint32

func (i Binary) String() string {
    return strconv.FormatUint(i.Get(), 2)
}

func (i Binary) Get() uint64 {
    return uint64(i)
}

func (i Binary32) String() string {
    return strconv.FormatUint(uint64(i.Get()), 2)
}

func (i Binary32) Get() uint64 {
    return uint64(i)
}

func main() {
    
     b := Binary(200)
     b32 := Binary32(200)
    
     s := Stringer(b)
     s32 := Stringer(b32)
    
     any := (interface{})(b)
    
     fmt.Println(s.String())
     fmt.Println(s32.String())
    
     fmt.Println(ToString(any))
    
     var nothing interface{}

     nothing = uint64(200)
     fmt.Println(nothing)

     var face Stringer
    
     fmt.Println(face)
}
```
















