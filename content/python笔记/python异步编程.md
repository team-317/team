---
title: python异步编程
author: team317
Date: 2022-03-11
categories:  
  - "python笔记"
tags:  
  - "异步"
  - "python"
---

**本篇blog所讨论的问题：**

1.python异步编程的过程

2.python异步编程和多线程编程的区别

3.python异步程序在notebook中的运行问题<!--more-->

### python异步编程的过程
python异步编程的和协程有着很大的关系，协程也称为细粒度线程，协程可以通过yield关键字设置多个返回点并多次接收参数，由于协程是单线程的，所以并不需要设置锁等机制。使用yield关键字定义的是经典协程(classic coroutines)，这类协程需要通过next、send等函数来操作协程，与之相关的还有委派协程，这些内容在流畅的python一书中有详细讲解。

下面是一个classic coroutines：

```python
def classic():
  res1 = yield '返回值1'
  res2 = yield '返回值2'

mycoro = classic()
next(mycoro)  # 此时协程处于CREATED状态
mycoro.send('传递给res1')  # 在调用后协程处于RUNNING状态，执行完后处于SUSPENDED状态
mycoro.send('传递给res1')  # 执行完后协程处于CLOSED状态，并抛出StopIteration异常
```

异步编程中使用的协程叫做原生协程(native coroutines)与classic协程的使用方式很不一样，它没有send，没有next，也没有yield，但它也叫做协程，刚开始学习时我总会用classic协程的运行方式来理解它，出现了很多困扰。native协程不会设置多个返回点，它由async def func进行定义。

异步编程也是单线程的，在它的背后有一个成为loop的循环，由他来调度相互独立的协程实例。下面是一个示例：

```python
import asyncio
async def func(n):
  await asyncio.sleep(.1)
  return f"返回值{n}"

async def main():

  tasks = [asyncio.create_task( func(1)), 
           asyncio.create_task( func(2))]  # <1>
  
  # 将协程交给asyncio来处理
  results, _ = await asyncio.wait(tasks)  # <2>
  print(results)

asyncio.run( main())  # <3>
```
关于代码后面的标号说明如下：

<1> 用列表保留两个协程实例，并分别传入参数，两个协程相互独立，**用不到彼此的返回结果**；

<2> 将协程交给asyncio来处理，其背后有一个loop调度程序用于调度协程，当第一个协程因执行asyncio.sleep(.1)而阻塞时，调度程序会将cpu的控制权交给第二个协程，这样便能充分利用cpu。

<3> 在run函数中进行了两步操作：先创建一个loop，再将任务交给loop进行调度。

当协程执行I/O任务而被阻塞时，**与当前协程相互独立的另一个协程**便会被调度器调度，从而得到CPU的使用权，继续运行下去。所以协程能加快I/O密集型的程序的运行。从这里也可以看出，native协程的作用和classic协程的作用很不一样的。前者用于异步编程，后者则常用于同步。

### python异步编程和多线程编程的区别

python中可以进行过线程编程，它会创建多个线程来执行任务，但由于收到GIL锁的限制，同一时刻只能有一个线程获得CPU的使用权，即使CPU是多核的。GIL使得python中的多线程无法充分利用CPU。不过，当某个线程处理I/O任务时，它会被阻塞，同时将CPU的控制权交给另一个线程。所以python多线程虽然不能加速CPU密集型的任务（甚至还会因为线程的切换开销减慢其速度），但却能加速I/O密集型的任务。

对比pyhon多线程编程和异步编程，看起来两者都只能加速I/O密集型的任务，看上去没有太大的区别，但由于两者的工作方式不同，使得其效果也很不一样。由于协程的开销相当于调用一个函数的开销，相比于线程切换开销小得多，所以python异步编程对I/O密集型的任务加速效果更好些。（其他语言如Java的多线程不受GIL的限制，情况就不清楚了）

### python异步程序在notebook中的运行问题

在notebook中执行`asyncio.run( main()) `时，会出现`asyncio.run() cannot be called from a running event loop`的错误，这是由于notebook本身就是一个loop，而run函数会尝试新建一个loop，而一个线程只能有一个loop，于是产生了这个错误。在stackflow中提供了两种解决方案：

方案一：直接在notebook中用await驱动main()，，即把`asyncio.run( main()) `改为`await main()`。await关键字只能在async定义的函数内使用，如果在外部使用，则会报错。但在notebook中则不同，这大概是由于notebook本身就是一个async定义的协程，使得await可以直接使用。

方案二：获取运行notebook的loop，并将main()作为任务加入其中，代码如下：
```python
loop = asyncio.get_running_loop()
tsk = loop.create_task( main() )
```

**参考资料**

[python async异步编程（asyncio 学python必备）](https://www.bilibili.com/video/BV1cK4y1E77y?p=1)

[asyncio.run() cannot be called from a running event loop](https://stackoverflow.com/questions/55409641/asyncio-run-cannot-be-called-from-a-running-event-loop)


