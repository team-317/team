---
title: "Queue的put、join和task_one"
description: 使用Queue实现多线程，并通过join和task_one完成同步
date: 2022-03-07
categories:
  - "Python笔记"
tags:
  - "python"
  - "多线程"
---


## Introduction to Go Templates


在学习**Queue**时**task_one**时让我迷惑了很久，理清之后写下了这篇笔记。

**python**中的**queue**库提供了一个线程安全的类**Queue**，它和普通的队列一样具有先进先出的特点，不同的在于它对与空队列的处理。

**Queue**对象使用**get**弹出队头的元素，使用**put**将元素插入队尾。**Queue**的源码并不长，在源码中**Queue**内部设置了条件变量，当队列为空而执行**get**操作时，该操作将会被阻塞；当队列满而执行**put**操作时，该操作同样会被阻塞。此外**queue**内部设置的队列是**collections**提供的**deque**，这是一个线程安全的双端队列，对它进行入队和出队操作都是原子操作，而**Queue**的**get**和**put**操作沿用了这一操作，所以**Queue**也是线程安全的，这使得**Queue**常用于多线程中。

接下来转入正题。

要理解**task_one**，就需要理解与**put**、**join**、**task_one**三个操作都相关的内部属性**unfinished_tasks**。

每当执行一次**put**操作，**unfinished_tasks**就加一，可理解为**put**代表增加了一个任务；

每执行一次**task_one**操作，**unfinished_tasks**就减一，可以把**task_one**放在**get**操作之后，当**get**成功执行后，在执行**task_one**使得**unfinished_tasks**减一，代表完成了一个任务；

而**join**则通过判断**unfinished_tasks**是否为零执行**wait**操作；

在**python**的官方文档中有关于**task_one**的代码样例，我在样例的基础上增加了关于**unfinished_tasks**的注释，以便读者理解：

```python
import threading, queue

q = queue.Queue()

def worker():
    while True:
        item = q.get()
        print(f'Working on {item}')
        print(f'Finished {item}')
        q.task_done()	# unfinished_tasks += 1

# turn-on the worker thread
threading.Thread(target=worker, daemon=True).start()

# send thirty task requests to the worker
for item in range(30):
    q.put(item)		# unfinished_tasks -= 1
print('All task requests sent\n', end='')

# block until all tasks are done
q.join() # if unfinished_tasks != 0: wait()
print('All work completed')
```




这里有一点要注意，由于**put**操作位于主线程中，所以在`q.join()`之前一定会完成30次**put**操作，与此同时子线程会执行**get**操作和**task_one**操作，所以在执行`q.join`之前可能有两种情况：

**case1**: 主线程先完成30次**put**，使得**unfinished_tasks**>0，于是主线程在`q.join()`处阻塞；

**case2**: 子线程执行**get**操作比主线程快，随后执行的**task_done**使得**unfinished_tasks**在30次**put**操作之前变为0（如果在这种情况下执行`q.join`，则不会发生阻塞），此时队列为空，子线程执行**get**操作后被阻塞，当主线程再次完成一次**put**操作后子线程解除阻塞继续执行，如此循环。

最后还有一点，**worker**是一个死循环，所以当主线程结束后，子线程其实并不会结束，它依然会继续存在。但由于队列为空，所以它会一直阻塞在**get**操作中。