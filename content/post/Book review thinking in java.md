+++
author = "author"
date = "2016-07-26T09:50:57+08:00"
description = "Thinking in java"
draft = false
keywords = ["key", "words"]
tags = ["Java", "Book Notes"]
title = "Book Review: Thinking in Java"
topics = ["topic 1"]
type = "post"

+++

## Reading Book

  断断续续的看了将近一个多月，算是系统复习下，一来不能让书白买了，二来毕竟很长一段时间没有做过大规模的Java开发了，Java还是很有意思的，后面还会有很多Book Review。
  需要说明的是，后面几个章节没有什么笔记。原因是他们都太工程化了，需要更多的实践，就没再记录。后面尽量每个topic都有单独的blog。
                  学无止境

### 第五章 初始化与清理

1. 根据参数列表不同进行函数重载，无法根据返回值进行函数重载。因为函数调用者不关心函数的返回值，编译器就无法判定。参数列表的不同顺序也能区分不同的函数，但是这样维护性不够好，不建议这样做。
2. 如果自己类里面已经定义了一个构造器，无论是否有参数，编译器都不会再生成默认的构造器了，跟C++一样。
3. this 关键字代表当前对象，可以用this调用一个构造器，但是不能同时调用两个；也必须将构造器调用置于最开始的地方，否则编译器会报错。
4. finalize 用于验证终结条件。垃圾回收和终结，都不保证一定会发生。如果java虚拟机并未面临内存耗尽的情况。
  1. 对象可能不被垃圾回收
  2. 垃圾回收不等价与析构
  3. 垃圾回收只与内存有关。
  4. 终结函数要避免使用
5. 在定义类成员变量的地方为其赋值。构造器初始化之前，类成员变量就已经进行了初始化。类内部，变量定义的先后顺序决定了初始化的顺序。即使变量定义散布于方法定义之间，他仍旧会在任何方法被调用之前得到初始化。
  1. 初始化顺序是先静态对象，并只在Class对象首次加载时执行一次；
  2. new 分配内存；
  3. 执行字段定义处的初始化动作；
  4. 执行构造器。

6. 静态初始化只在Class 对象首次加载的时候进行一次。非静态实例初始化，与静态初始化子句一模一样，只是少了static关键字。这种语法对于支持匿名内部类的初始化是必须的。
  实例初始化字句：

  ```
  class Mug {
  Mug(int marker) {
    print("Mug(" + marker + ")");
  }
  void f(int marker) {
    print("f(" + marker + ")");
  }
}

public class Mugs {
  Mug mug1;
  Mug mug2;
  {
    mug1 = new Mug(1);
    mug2 = new Mug(2);
    print("mug1 & mug2 initialized");
  }
  Mugs() {
    print("Mugs()");
  }
  Mugs(int i) {
    print("Mugs(int)");
  }
  public static void main(String[] args) {
    print("Inside main()");
    new Mugs();
    print("new Mugs() completed");
    new Mugs(1);
    print("new Mugs(1) completed");
  }
} /* Output:
Inside main()
Mug(1)
Mug(2)
mug1 & mug2 initialized
Mugs()
new Mugs() completed
Mug(1)
Mug(2)
mug1 & mug2 initialized
Mugs(int)
new Mugs(1) completed
```

7. 可变参数列表：void f(Object... args),除了Object之外，其他的数据类型也可以作为可变参数列表。

### 第六章 访问权限控制
1. 访问权限等级：public，protected，包访问权限，private。
2. 一个java源文件为一个编译单元，每个编译单元只能有一个public类。java可运行程序是一组可以打包压缩为一个java文档文件的.class文件，java解释器负责这些文件的查找、装载和解释。
3. 包访问权限，默认包访问权限没有任何关键字。默认包：处于相同的目录并且没有给自己设定任何包名称，这样的文件自动看作是隶属于该目录的默认包之中。
4. 类既不可以是private的，也不可以是protected。如果没能为类访问权限指定一个访问修饰符，它就会默认得到包访问权限。相同目录下的所有不具有明确package声明的文件，都被视作该目录下默认包的一部分。

### 第七章 复用类
1. 组合语法和继承语法，带参数的构造器，使用super调用，并传递适当的参数。组合技术通常用于在新类中使用现有类的功能而非它的接口这种情形。
protected：任何继承于此类的导出类或者其他任何位于同一个包内的类来说，是可以访问的。protected提供了包内访问权限。
2. 代理：将一个成员对象置于所要构造的类中，就像组合，但与此同时我们在新类中暴露了该成员对象的所有方法，就像继承。
3. 覆写与重载：@Override
4. 向上转型：导出类转换为基类。
5. final：一个既是static又是final的域只占据一段不能改变的存储空间。Blank Final：必须在域的定义处或者每个构造器中用表达式对final进行赋值。final参数，这一特性主要用来想匿名内部类传递数据。final方法，只有在想明确禁止覆盖时，才将方法设置为final。final和private关键字，所有的private的方法都隐式地指定为final的。final类，类不做任何改动，不能继承。

### 第八章 多态
1. 面向对象程序设计语言中，多态是继数据抽象和继承之后的第三种基本特征。
2. java中除了static方法和final方法之外，其他所有的方法都是后期绑定。只有非private的方法才能被覆盖。
3. 初始化过程：将分配给对象的存储空间初始化成二进制的零；调用基类构造器；按照声明的顺序调用成员的初始化方法；调用导出类的构造器主体。基类构造器内调用final方法，既不能被覆盖的方法。
4. 用继承表达行为间的差异，并用字段表达状态上的变化。

### 第九章 接口
1. 接口和内部类为我们提供了一种将接口与实现分离的更加结构化的方法
2. 抽象方法，abstract void f（），包含抽象方法的类为抽象类。
3. interface关键字使抽象的概念更向前迈进了一步。提供了接口部分，没有提供任何相应的具体实现，接口被用来建立类与类之间的协议。
4. 创建一个能够根据所传递的参数对象的不同而具有不同行为的方法，被称为策略设计模式。通过接口容易实现策略模式，同一个入口点，不同的实现实例来调用。
    适配器设计模式：适配器中的代码将接受你所拥有的接口，并产生你所需要的接口。将接口从具体实现中解耦使得接口可以应用于多种不同的的具体实现。

    ```
    //FilterAdapter 为一个适配器，实现了process 接口。
    class FilterAdapter implements Processor {
    }
    ```

5. 使用接口的原因：可以能够向上转型为多个基类型；使用抽象基类相同，防止客户端程序员创建该类的对象，并确保这仅仅是建立一个接口。接口的一种常见的用法就是策略设计模式。
6. 通过interface关键字提供伪多重继承机制，让方法接受接口类型，是一种让任何类都可以对该方法进行适配的方式。
7. 接口中的变量都是自动是static和final的。接口是实现多重继承的途径，而生成遵循某个接口对象的典型方式就是工厂方法设计模式，在工厂对象上调用的是创建方法，而该工厂对象将生成某个实现的对象。通过这种方式，代码完全与接口的实现分离，这样可以透明的使得我们将某个实现替换为另一种实现。
8. 优先选择类而不是接口，从类开始，如果接口的必需性变得非常明确，那么就进行重构。
9. interface前面加上关键字public，则所有成员都是public的，否则只具有包访问权限。

### 第十章 内部类
1. 内部类自动拥有对其外围类所有成员的访问权。构建内部类时，需要一个指向其外围类对象的引用。内部类对象会秘密的捕获一个外部类对象的引用。拥有外部类对象之前是不可能创建内部类对象的。因为内部类对象会暗暗地连接到创建外部类对象上，除非是嵌套类，即静态内部类。
2. 在拥有外部类对象之前是不可能创建内部类的。但如果创建是嵌套类，即静态内部类，那么它不需要对外部类对象的引用。

```
public class Parcel3 {
  class Contents {
    private int i = 11;
    public int value() { return i; }
  }
  class Destination {
    private String label;
    Destination(String whereTo) { label = whereTo; }
    String readLabel() { return label; }
  }
  public static void main(String[] args) {
    Parcel3 p = new Parcel3();
    // Must use instance of outer class
    // to create an instance of the inner class:
    Parcel3.Contents c = p.new Contents();
    Parcel3.Destination d = p.new Destination("Tasmania");
  }
}
```

3. 局部内部类：在方法的作用域内创建一个完整的内部类；匿名内部类，工厂方法可以使用匿名内部类实现。Java内部类主要分为成员内部类，局部内部类，匿名内部类，静态内部类。
4. 嵌套类：将内部类声明为static。创建嵌套类对象，不需要其外围类的对象；不能从嵌套类的对象中访问非静态的外围类对象。普通的内部类不能有static数据和字段，也不能包含嵌套类。嵌套类可以包含。
5. 为啥需要内部类：每个内部类都能独立继承自一个接口的实现，所以无论外围类是否已经继承了某个实现，对于内部类没有影响。它使得多重继承的解决方案变得完整，内部类允许继承多个非接口类型。内部类提供了更好的封装，除了外围类，其他类都不能访问。
6. 闭包：是一个可调用的对象，它记录了一些信息。内部类是面向对象的闭包，通过内部类实现闭包，即可实现回调。

### 第十一章 持有对象
1. 通过使用泛型，就可以在编译期防止将错误的类型对象放置到容器中。
2. 迭代器是一个对象，它的工作是遍历并选择序列中的对象。iterator，ListIterator。
3. 当你有一个接口，并需要另一个接口时，编写适配器可以解决问题。


### 第十二章通过异常处理错误
1. 终止和恢复：大型程序一般不实用恢复。直接终止程序，利于代码编写和维护。
2.

### 第十三章 字符串
1. StringBuilder创建字符串更加高效；

### 第十四章 类型信息
1. Class对象就是用来创建类所有的常规对象的。使用Class的newInstance 创建的类必须有默认的构造函数。
2. RTTI：运行时，识别一个对象的类型；java使用Class对象执行RTTI。RTTI必须在编译时已知的对象。instanceof保持了类型的概念，class比较没有考虑继承，只看是否为这个确切的类型。
3. 类字面常量，xxx.class，使用其创建对象时，并不会自动初始化该Class对象。初始化延迟到对静态方法或者非常数静态域即非编译期常量进行首次引用时。如果一个static域不是final的，那么在访问时总是要进行连接和初始化。
4. 向Class引用提供泛型语法的原因是为了提供编译器类型检查。
5. 工厂方法设计模式；将对象的创建工作交给类自己去完成:

```
//interface
public interface Factory<T> { T create(); } ///:~

class Part {
  public String toString() {
    return getClass().getSimpleName();
  }
  static List<Factory<? extends Part>> partFactories =
    new ArrayList<Factory<? extends Part>>();
  static {
    // Collections.addAll() gives an "unchecked generic
    // array creation ... for varargs parameter" warning.
    partFactories.add(new FuelFilter.Factory());
    partFactories.add(new AirFilter.Factory());
    partFactories.add(new CabinAirFilter.Factory());
    partFactories.add(new OilFilter.Factory());
    partFactories.add(new FanBelt.Factory());
    partFactories.add(new PowerSteeringBelt.Factory());
    partFactories.add(new GeneratorBelt.Factory());
  }
  private static Random rand = new Random(47);
  public static Part createRandom() {
    int n = rand.nextInt(partFactories.size());
    return partFactories.get(n).create();
  }
}

class Filter extends Part {}

class FuelFilter extends Filter {
  // Create a Class Factory for each specific type:
  public static class Factory
  implements typeinfo.factory.Factory<FuelFilter> {
    public FuelFilter create() { return new FuelFilter(); }
  }
}

class AirFilter extends Filter {
  public static class Factory
  implements typeinfo.factory.Factory<AirFilter> {
    public AirFilter create() { return new AirFilter(); }
  }
}

class CabinAirFilter extends Filter {
  public static class Factory
  implements typeinfo.factory.Factory<CabinAirFilter> {
    public CabinAirFilter create() {
      return new CabinAirFilter();
    }
  }
}

class OilFilter extends Filter {
  public static class Factory
  implements typeinfo.factory.Factory<OilFilter> {
    public OilFilter create() { return new OilFilter(); }
  }
}

class Belt extends Part {}

class FanBelt extends Belt {
  public static class Factory
  implements typeinfo.factory.Factory<FanBelt> {
    public FanBelt create() { return new FanBelt(); }
  }
}

class GeneratorBelt extends Belt {
  public static class Factory
  implements typeinfo.factory.Factory<GeneratorBelt> {
    public GeneratorBelt create() {
      return new GeneratorBelt();
    }
  }
}

class PowerSteeringBelt extends Belt {
  public static class Factory
  implements typeinfo.factory.Factory<PowerSteeringBelt> {
    public PowerSteeringBelt create() {
      return new PowerSteeringBelt();
    }
  }
}

public class RegisteredFactories {
  public static void main(String[] args) {
    for(int i = 0; i < 10; i++)
      System.out.println(Part.createRandom());
  }
}

```
6. 动态代理：代理模式是为了提供额外的或不同的操作，而插入的用来代替实际对象的对象。任何时刻只要你想要从额外的操作从实际的对象分离出来，这就是代理模式要达到的目的，封装修改。
2. 反射：反射机制，.class文件在编译时是不可获取的，在运行时打开和检查class文件。
3. 类三个步骤：加载、链接、初始化。instanceof 保持了类型的概念。


### 第十五章 泛型
1. 主要目的之一：用来指定容器要持有什么类型的对象，而且编译器来保证类型的正确性。
2. 泛型方法，泛型方法不必指明参数类型，需要将泛型参数列表置于返回值前。编译器会为我们找出具体的类型，这称为类型参数推断。
```
public class GenericMethods {
  public <T> void f(T x) {
    System.out.println(x.getClass().getName());
  }
  public static void main(String[] args) {
    GenericMethods gm = new GenericMethods();
    gm.f("");
    gm.f(1);
    gm.f(1.0);
    gm.f(1.0F);
    gm.f('c');
    gm.f(gm);
  }
}
```

3. 在泛型代码内部，无法获得任何有关泛型参数类型的信息。数组可以向上转型，仅在编译时期：

```
class Fruit {}
class Apple extends Fruit {}
class Jonathan extends Apple {}
class Orange extends Fruit {}

public class CovariantArrays {
  public static void main(String[] args) {
    Fruit[] fruit = new Apple[10];
    fruit[0] = new Apple(); // OK
    fruit[1] = new Jonathan(); // OK
    // Runtime type is Apple[], not Fruit[] or Orange[]:
    try {
      // Compiler allows you to add Fruit:
      fruit[0] = new Fruit(); // ArrayStoreException
    } catch(Exception e) { System.out.println(e); }
    try {
      // Compiler allows you to add Oranges:
      fruit[0] = new Orange(); // ArrayStoreException
    } catch(Exception e) { System.out.println(e); }
  }
}
```

4. 通配符：List<? extends MyClass>， 读作 "具有任何从MyClass继承的类型的列表"，通配符引用的是明确的类型。超类型通配符：<? super MyClass>，可以接受MyClass类型或者从MyClass类型导出的类型。无界通配符<?>
5. 任何基本类型不能作为类型参数。autoboxing 提供了一种可行方案。
5. 装饰器模式使用分层对象来动态的透明地向单个对象添加责任。
6. Java泛型是通过擦除来实现的。类型参数将擦除到它的第一个边界。类型变量在没有指定边界的情况下被擦除为Object。

### 第十六章 数组
1. 数组与泛型不能很好地结合；数组必须知道它们所持有的确切类型。但是可以参数化数组本身的类型；

### 第十七章 容器深入研究
1. 如果要使用自己的类作为HashMap的键，必须同时重载hashCode 和 equals 方法。

### 第十八章 Java I/O 系统
1. 需要理解Java I/O 系统的演化过程，如果缺乏历史的眼光，很快我们就会对什么时候该使用哪些类，以及什么时候不该使用他们而感到迷惑。
2. 对象序列化的概念加入到语言中是为了支持两种特性：
  1. RMI，使得存活于其他计算机上的对象使用起来像是存活于本机一样。
  2. Java Beans，Beans信息需要保存，在下一次启动时可以能够自动恢复。
3. transient 关键字: 关闭字段的序列化


### 第十九章 枚举类型
1. switch中可以直接使用enum。
2. 命令模式：需要有一个只有单一方法的接口，然后从该接口实现具有各种不同行为的多个子类。

```
interface Command {void action();}

EnumMap<enumType, Command> em = new EnumMap<enumType, Command>(enumType.class);
em.put(ACTION_ONE, new Command() {
  public void action() {print("ACTION_ONE fired!");}
  })
```

3. enum 实例可以编写方法，从而为每个enum实例赋予不同的行为。
4. 职责链模式：程序员以多种不同的方式来解决一个问题然后将它们链接在一起。当一个请求到来时，它遍历整个链，直到链中的某个解决方案能够处理该请求。
5. enum类型非常适合创建状态机。
6. 多路分发，java只支持单路分发。例如a.plus(b)，不知道a，b的类型时，必须自己来判定其他的类型，从而实现自己的动态绑定行为。
  1. 使用接口超类，每个类型实现接口。
  2. 使用enum分发。

### 第二十章 注解

### 第二十一章 并发
1. Java的线程机制来自C的低级pthread线程。
2. synchronized，同步方法，不属于方法特征签名，覆盖方法上使用。volatile解决可视性问题。``` javap -c classname ``` 看class字节码。
3. 临界区也叫同步控制块，一个代码段，多个线程同时访问。同一个互斥锁可以被同一个线程多次获得。
