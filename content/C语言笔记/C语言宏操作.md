---
title: C语言宏操作
author: team317
Date: 2021-05-19
categories:  
  - "C语言笔记"
tags:  
  - "C"
---


**编译和宏** 

编译可分为两个阶段：编译和链接

step1:编译阶段进行语法检查

step2:链接阶段将各个相互关联的模块拼接在一起
<!--more-->

### 编译阶段

编译指令：`g++ -c xxx.cpp`

在编译阶段通过之后会生成后缀为`.o`的中间文件；通过命令`nm -C xxx.o`可以查看该文件的内容；



**例：**编译并查看一下compile_test.o文件的内容

`compile_test.cpp`的内容如下

```cpp
#include<stdio.h>
int add(int a, int b){
    return a+b;
}
int main(){
    printf("Hello world!");
    printf("The value of 3+4 is %d.", add(3,4));
    return 0;
}
```

通过执行上面提到的两条代码，中间结果如下：![image-20210519181124259](https://img-blog.csdnimg.cn/img_convert/08159e7cfd8cda3e8817960fc5addf9d.png)

需要关注的是下面这个方框，其中T标志表示当前文件的模块，U标志表示需要链接的模块；显然add函数是当前文件的，无需链接，但printf函数是系统定义的，需要到系统库中找到printf的声明和定义并进行链接。



### 预处理语句——宏定义

#### 宏的类型

+ 宏有三种类型：

  + 定义符号常量  `#define PI 3.1415926`

  + 定义宏表达式  `#define ADD(a,b)  a+b`

  + 定义代码片段 

    ```
    #define HELLO(msg){	\
    	printf("%s",msg);	\
    }
    ```

#### 宏的处理和作用

对宏的理解，宏是预处理语句，也就是说**它是在编译的时候发挥作用**的，它的作用是什么呢？宏的格式为`#define 标识符 替换内容`，宏作用就是**将宏标识符更改为替换内容**。



#### 插曲：彩色文字!

文字在显示时可以分为三部分：`字形码，前景色、背景色`；

在C语言中，printf其实是可以设置文字的样式的，在打印内容之前插入：`\033[a,b,cm`可以设置打印文字的显示效果，其中a，b，c是三个控制编号，见下图

<img src="https://gitee.com/Team317/pictures/raw/master/images/image-20210517214327783.png" alt="image-20210517214327783" style="zoom:50%;" />

有了这种配置方式就可以打印彩色文字了，例如：

```c
printf("\033[1,32,40mHello world!");
```

为防止先前的设置影响后面输出的文字，一般在结尾会重置所有属性，如下：

```c
printf("\033[1,34,40mColorful words!\033[0m");
```

### 宏的使用

#### 宏的妙用①——用宏设置文字属性

由于宏具有替换的功能，所以可以像处理字符串的连接操作一样来拼接代码，上面对文字颜色的设置可以用宏来完成：

```c++
// 宏定义
#define RED(msg)    "\033[0;31m" msg "\033[0m"

// 使用方式
int main(){
    printf(RED("Hello World!"));
    return 0;
}
```

对于打印语句，在VSCode中有如下提示：

![image-20210519194743580](https://img-blog.csdnimg.cn/img_convert/7f10f6859ceafb6cca3c33ecd5586359.png)

RED("Hello world")被扩展为`"\033[0;31m" "Hello World!" "\033[0m"`；所以这条语句等价于`printf("\033[1,32,40mHello world!");`



#### 宏的妙用②——替换代码段：比较操作

上面的`RED`是一个宏表达式，但它还没有完全展示宏的作用，宏代码段能够替换代码段，这更能展现宏的作用：

```c
// 相等判断
#define EXPECT_EQ(a,b){    \
    if(!((a) == (b))){  \
        printf("Error\n");  \
    }   \
}
//使用方式
int main(){
    EXPECT_EQ(3,4);
    return 0;
}
```

同样的看一下VSCode对宏的扩展：

![image-20210519201725997](https://img-blog.csdnimg.cn/img_convert/ddbd97c00d897c5fdaa7fc0cd544ce55.png)

注意外围的花括号，这个括号不是必须的，**使用花括号括起来后宏中定义的变量为局部变量**。



#### 宏的妙用③——嵌套替换

```c
// 比较判断
#define EXPECT(a, comp, b){    \
    if(!((a) comp (b))){  \
        printf("Error\n");  \
    }   \
}
// 大于等于判断
#define EXPECT_LE(a,b)  EXPECT(a, >=, b)
// 不等判断
#define EXPECT_NE(a,b)  EXPECT(a, !=, b)

// 使用方式
int main(){
    EXPECT_LE(1,9);
    EXPECT_NE(1,9);
    return 0;
}
```

VSCode中对宏的提示如下：

<img src="https://gitee.com/Team317/pictures/raw/master/images/image-20210519200044293.png" alt="image-20210519200044293" style="zoom: 67%;" />

`EXPECT_LE`中使用了`EXPECT`，当宏进行替换时，`EXPECT_LE`就会替换为下面的代码段：

```c
if(!((a) >= (b))){
    printf("Error\n");
}
```

很奇妙的是，在`EXPECT_LE`传给`EXPECT`的参数comp为`>=`，注意这不是字符串，所以可以看出，宏替换是很朴素的替换，它不会对传入的内容做任何处理，上面的代码`EXPECT_LE(1,9);`在mian中也可直接写作`EXPECT(1,>=,9);`

之所以要加一层嵌套是为了提高代码的复用性，**不用EXPECT的话，EXPECT_LE和EXPECT_NE这两个宏除了比较符号不同，其他的内容都相同，有很大的相似度**。



#### 宏的运用——函数测试

在leetcode中，给定的算法题都有测试用例，其实用宏也可以完成测试功能，这里举个简单的例子来说明：

```c
#include<stdio.h>

#define COMP(a,b)\
int result; \
result = a+b;

#define TEST(ADD, val){ \
    ADD    \
    if(result == val){  \
        printf("get a correct result!");    \
    }   \
}

/* 用宏进行函数测试 */

int main(){
    int a=3, b = 4;
    TEST(COMP(a,b),7);
}
```

注意，在定义宏`COMP`时外围没有使用花括号，**只要宏之后有换行符"\\"，那么这个宏就没有结束，就可以继续在后面添加语句**。在编译器看来，**宏其实是一行代码，里面可以包含多条代码**，对TEST进行宏展开效果如下：

![image-20210521093530715](https://img-blog.csdnimg.cn/img_convert/0e053822956c4373fcc83b2a234026b7.png)

这样就能完成一个简单的测试了。

### 小结

宏在C中起到的是替换作用，需要注意的是，这个替换过程是在预处理阶段完成的，预处理阶段还没开始进行编译，当预处理完所有宏都被替换为具体的内容之后才开始编译。

