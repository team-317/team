---
title: 优先使用malloc创建链表节点
author: team317
Date: 2021-03-09
categories:  
  - "C++笔记"
tags:  
  - "动态内存"
---


### 1、链表节点的动态分配

在用一条打印语句打印链表节点值时，发现链表节点的信息发生了改变，见下图：

![](https://img-blog.csdnimg.cn/20210309113131433.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)

<!--more-->
![](https://img-blog.csdnimg.cn/20210309113109678.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)


后来才知道在这之前调用了一个插入节点的函数Insert，这个节点的创建方式是直接通过`LNode node;`来创建的，这样做的结果是节点node为局部变量，当函数Insert结束后这个节点所在的空间将被释放。

但由于这片空间还没有被再次利用，所以在打印语句之前看上去一切正常，知道执行打印语句时这片空间被打印语句当作缓冲区被利用，此时内存地址中的值发生改变，也就发生了图二的情况。



### 2、链表节点的释放

如图所示，在执行程序时报错：Trace/breakpoint trap

<img src="https://img-blog.csdnimg.cn/20210309113313216.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70" width="60%"/>

经了解后发现节点s的也是直接通过`DNode node;`这样的方式创建的，虽然s创建的位置在main函数中，在执行过程中不会像局部变量那样被释放，但当要释放这个节点时，却不能使用free函数，因为free函数只能释放由malloc函数申请创建的变量。



**通过上面两个错误，我吸取了一个教训，在创建链表节点时，无论在那个地方创建，都应该使用malloc进行动态分配。**