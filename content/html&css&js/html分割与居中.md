---
title: html分割与居中
author: team317
Date: 2020-10-02
categories:  
  - "html&css&js"
tags:  
  - "html"
---


### 选中第一个以外的元素
排版一个天气网站，下面这部分页面由四个li组成，需要在每个li左侧插入一条竖线作为分割（这条竖线是一张图片），要求第一个li的背景图中不能插入竖线，则需要选中除第一个li之外的其他li插入图片。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201002094047860.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70#pic_center)
<!--more-->

```c
.weather_list{
    margin:0 auto;
    text-align: center;
}
.weather_list li{
    width: 240px;
    height: 240px;
    display: inline-block;
}
/* 选中除一个li之外的其他li */
.weather_list li:not(:first-child){  
    background: url("../img/line.png") no-repeat left;
}
```
对比一下选中第一个li的选择器：
```c
.weather_list li:first-child
```
注意插入":not"的位置，不然选择器会作废。

### 用css插入图片
还是上面的这个页面，背景中需要插入竖线，要求用css完成，这个时候不能在html文件中使用img标签，可以通过在css文件中设置背景图片来实现：
```c
.weather_list li:not(:first-child){  
    background: url("../img/line.png") no-repeat left;
}
```
在设置完url之后一般需要加上 " no-repeat " 防止因为图片大小尺寸不足以重复的方式铺满所在块。后面的left用于设定图片的位置。

### 居中对齐
html中常常需要使用大量的对齐操作，最近学到两种居中对齐方式。

一种是用`margin:auto` 自动对齐，这要求其父元素的宽高是固定好大小的，如其父元素大小为`height:300px; width:400px;` ，这个时候可以用margin对齐。水平居中用`margin:0 auto`，垂直居中用`margin:auto 0` 。
此外再记一下`margin:30px 20px 25px 30px` 设置的含义，这分别设置的是上、右、下、左四个方向的margin值。

另一种对齐方式是使用`text-align:center`，这要求该元素的父元素是一个块级元素，可参考博客：[CSS水平居中+垂直居中+水平/垂直居中的方法总结](https://blog.csdn.net/weixin_37580235/article/details/82317240#%E6%B0%B4%E5%B9%B3%E5%B1%85%E4%B8%AD%C2%A0)