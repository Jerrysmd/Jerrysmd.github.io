# Shallow Copy and Deep Copy in JAVA

Cloning is a process of creating an exact copy of an existing object in the memory. In java, clone() method of java.lang.Object class is used for cloning process. This method creates an exact copy of an object on which it is called through field-by-field assignment and returns the reference of that object. Not all the objects in java are eligible for cloning process. The objects which implement Cloneable interface are only eligible for cloning process. Cloneable interface is a marker interface which is used to provide the marker to cloning process. Click here to see more info on clone() method in java.
<!--more-->

## Preface

Object  类中有方法clion()，具体方法如下：

```java
protected native Object clone() throws CloneNotSupportedException;
```

1. 该方法由 `protected` 修饰，java中所有类默认是继承`Object`类的，重载后的`clone()`方法为了保证其他类都可以正常调用，修饰符需要改成`public`。
2. 该方法是一个`native`方法，被`native`修饰的方法实际上是由非Java代码实现的，效率要高于普通的java方法。
3. 该方法的返回值是`Object`对象，因此我们需要强转成我们需要的类型。
4. 该方法抛出了一个`CloneNotSupportedException`异常，意思就是不支持拷贝，需要我们实现`Cloneable`接口来标记，这个类支持拷贝。

为了演示，我们新建两个实体类`Dept` 和 `User`，其中`User`依赖了`Dept`，实体类代码如下：

Dept 类：

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Dept {
    private int deptNo;
    private String name;
}
```

User 类：

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {
    private int age;
    private String name;
    private Dept dept;
}
```

## Shallow Copy

对于基本类型的的属性，浅拷贝会将属性值复制给新的对象，而对于引用类型的属性，浅拷贝会将引用复制给新的对象。而像`String`，`Integer`这些引用类型，都是不可变的，拷贝的时候会创建一份新的内存空间来存放值，并且将新的引用指向新的内存空间。不可变类型是特殊的引用类型，我们姑且认为这些被`final`标记的引用类型也是复制值。

![shallowCopy](/posts/picture/ShallowCopy.png "shallowCopy")

**浅拷贝功能实现**

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User implements Cloneable{
    private int age;
    private String name;
    private Dept dept;
    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}
```

如何验证我们的结论呢？首先对比被拷贝出的对象和原对象是否相等，不等则说明是新拷贝出的一个对象。其次修改拷贝出对象的基本类型属性，如果原对象的此属性发生了修改，则说明基本类型的属性是同一个，最后修改拷贝出对象的引用类型对象即`Dept`属性，如果原对象的此属性发生了改变，则说明引用类型的属性是同一个。清楚测试原理后，我们写一段测试代码来验证我们的结论。

```java
public static void main(Strign[] args) thows Exception{
    Dept dept = new Dept(12,"市场部");
    User user = new User(18,"Java", dept);
    
    User user1 = (User)user.clone();
    System.out.println(user == user1);

    user1.setAge(20);
    System.out.println(user);
    System.out.println(user1);
    
    dept.setName("研发部");
    System.out.println(user);
    System.out.println(user1);
}
```

运行结果如下：

```java
false

User{age=18, name='Java', dept=Dept{deptNo=12, name='市场部'}}
User{age=20, name='Java', dept=Dept{deptNo=12, name='市场部'}}

User{age=18, name='Java', dept=Dept{deptNo=12, name='研发部'}}
User{age=20, name='Java', dept=Dept{deptNo=12, name='研发部'}}
```



## Deep Copy

相较于浅拷贝而言，深拷贝除了会将基本类型的属性复制外，还会将引用类型的属性也会复制。

![deepCopy](/posts/picture/DeepCopy.png "DeepCopy")

深拷贝功能实现

在拷贝user的时候，同事将user中的dept属性进行拷贝。

dept 类：

```java
@Data
@AllArgsConstructor
@NoArgsXonstructor
public class Dept implements Cloneable{
    private int deptNo;
    private String name;
    
    @Override
    public Object clone() throws CloneNotSupportedException{
        return super.clone();
    }
}
```

user 类：

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User implements Cloneable{

    private int age;
    private String name;
    private Dept dept;

    @Override
    protected Object clone() throws CloneNotSupportedException {
        User user = (User) super.clone();
        user.dept = (Dept) dept.clone();
        return user;
    }
}
```

使用浅拷贝的测试代码继续测试，运行结果如下：

```java
false

User{age=18, name='Java旅途', dept=Dept{deptNo=12, name='市场部'}}
User{age=20, name='Java旅途', dept=Dept{deptNo=12, name='市场部'}}

User{age=18, name='Java旅途', dept=Dept{deptNo=12, name='研发部'}}
User{age=20, name='Java旅途', dept=Dept{deptNo=12, name='市场部'}}
```

除此之外，还可以利用反序列化实现深拷贝，先将对象序列化成字节流，然后再将字节流序列化成对象，这样就会产生一个新的对象。

