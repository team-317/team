---
title: ipconfig各个ip的含义
author: team317
Date: 2021-05-03
categories:  
  - "python笔记"
tags:  
  - "网络"
---


有时候在执行ipconfig时，会显示出多个ip，如果对网络不熟的话，可能会傻傻分不清，不知道这些ip都是什么意思。这里对比了不同网络条件下电脑的ip的变化，方便你分辨这些不同的ip。
<!--more-->
#### 网络情况一：

在断网的情况下执行ipconfig：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503170645215.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)
这个时候显示的是我的虚拟机VirtualBox的ip情况，这个ip地址应该是系统分配的，不管有没有联网都会显示。



#### 网络情况二：

连接了wifi

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503170705754.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)


虚拟机的ip保持不变，这个时候多了一个无线局域网适配器WLAN的ip情况，这是我连接的wifi地址。



#### 网络情况三：

连接wifi后开热点
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503170718592.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)



这时候多了本地连接2，这是开热点后分配给接入设备的地址。

#### 结论

所以如果你要查看自己电脑的ip地址，执行ipconfig，其中的无线局域网适配器WLAN就是主机的ip地址。

而如果你要给接入设备设置代理，则代理中的ip应设置为本地连接的地址。

#### 代理ip的设置

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503170745266.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)

电脑上打开热点，用手机进行连接，在手机上找到连接的wifi，点击进入设置界面，在代理那一栏中将主机名设置为ipconfig命令下显示的本地连接的ip地址，端口可自定义设置，在合理范围内即可。

当设置代理后，手机在访问网络时所接收的信息都要经过电脑，电脑再将这些信息发送到手机上。

