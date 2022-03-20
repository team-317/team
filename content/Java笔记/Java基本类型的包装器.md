---
title: Java基本类型的包装器
author: team317
Date: 2022-03-20
categories:  
  - "Java笔记"
tags:  
  - "Java"
---

问题来自下面这段代码，哈希字典windows和needs的键值对意为"字符：该字符出现的次数"，if语句用于判断字符ch在windows和needs中的值是否相同。当这个值比较小时，if语句能够正常给出判断。但当这个值比较大时，例如为10000，即使两者相等，if判断给出的结果也为false。<!--more-->

```Java
HashMap<Character, Integer> windows = new HashMap<>();
HashMap<Character, Intefer> needs = new HashMap<>();
...
if(windows.get(ch) == needs.get(ch)){
    ...
}
```
理解这个问题有两个关键点，一是==操作符的含义，二是Java包装类的装箱和拆箱。

对于基本类型，==用于比较两个变量的值，而对于对象变量，==用来判断两个对象变量是否指向同一个变量，即是否引用同一个变量。在这里`get`方法返回的是`Integer`对象，所以应该会比较两个返回对象是否相同。但考虑到Java的`Integer`会进行拆箱操作，所以起初我认为`get`方法返回`Integer`对象后会拆箱为两个整数值。

对于Java包装类的装箱和拆箱，有一个陷阱，查看Java用`valueOf`进行拆箱的源码:
```Java
@HotSpotIntrinsicCandidate
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)    //low=-127 high=128
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}
```
可以看到，当i的值在[-127, 128]时，会返回一个整数值，否则，会返回一个`Integer`对象。而返回`Integer`对象。此时通过==运算符比较的是两个对象是否是同一个对象。

在vscode中进行调试，当a=127,b=127时，a和b指向的是同一个对象，两者的记号均为9：

![](https://gitee.com/Team317/pictures/raw/master/images/20220320174036.png)

当a=128,b=128时，a和b指向的不是同一个对象，一个记号为9，另一个为10：

![](https://gitee.com/Team317/pictures/raw/master/images/20220320173319.png)

**所以对于非基本类型以及基本类型对应的包装类，在比较其两个对象是否相同时，都应该使用equals方法。**