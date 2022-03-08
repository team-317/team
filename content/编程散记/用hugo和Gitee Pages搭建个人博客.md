---
title: 用hugo和Gitee Pages搭建个人博客
author: team317
Date: 2022-03-08
categories:  
  - "编程散记"
tags:  
  - "git"
---

在本地搭建hugo博客并不麻烦，麻烦的在于上传到gitee或github，这里重点记录gitee pages的创建，创建过程也可以参考下面的一个视频：
[Hugo静态网站生成器，托管GitHub/Gitee Pages搭建个人站点 - 知乎
](https://www.zhihu.com/zvideo/1356065680542957568)
<!--more-->

**下面是被我踩过的坑**

### 选择gitee还是github?
最开始选github来创建Gitee pages，因为hugo文档上正好有部署介绍，但后面发现国内用git访问Github实在太卡了，即使按照网上的方式设置好了代理，也会出现git十几次才顺利执行的情况。遂选择国内的Gitee，之后就顺畅多了。

### 关于主题的选择
建议选择星星比较多的主题，最初选的主题捣腾了一天，本地运行很正常，页面很合我意，但部署到Gitee上之后样式完全显示不了，只有黑白的文字和页面。一直以为是自己哪一步出了问题，不断的补救，最后搞不来，不死心的去换了一个主题，然后又顺畅了。

### hugo生成网页的过程
每一个主题都会提供一个exampleSite，它的文件结构和你工作目录下的文件结构相似，将exampleSite中的文件夹复制一份到你的工作目录中，执行`hugo server -D themename`便可在本地搭建起该主题。其中themename即你选择的主题的名字。

**但要上传到Gitee中则还需先生成静态网页**，这一步很关键，执行`hugo --theme==themename`，这时会将文件生成到public目录下，你也可以执行`hugo --destination ./docs --theme==themename`将文件生成到docs目录下，之后部署到Gitee Pages上时将部署目录改为/docs。

执行后你能看到docs下生成了很多静态的html和xml文件，Gitee pages将通过这些静态网页来展示你的博客。

### 博客的更新
每次写完一篇博客都需要先提交再生成静态文件，最后上传到Gitee中，有点麻烦，所以写一个脚本执行这些指令会更方便，在win中可以编写如下脚本：
```cmd
@ ./shortcut.cmd
hugo -F --cleanDestinationDir
hugo --destination ./docs --buildDrafts  --theme=Mainroad
git status
git add .
git commit -m "update"
git push
```

每次写完后在终端执行shortcut.cmd便可完成上传。

但是！！！Gitee Pages的个人版在上传后不会自动重新更新博客，所以还得在Gitee Pages服务中点击"更新":

![](https://gitee.com/Team317/pictures/raw/master/images/20220308213341.png)

更新后可能由于浏览器对网页进行了缓存，还需要再等上几分钟才能看到更新后的博客。


### 头像的修改

在配置头像的时候遇到了一个问题，就是按文档说明我将头像avatar.png放在了工作目录下的img文件夹下，但无论我怎么刷新，博客中的头像都没有替换成我设置的那个头像，而是一直保持为原有的头像，我一直以为是缓存的问题（这是部分原因），但清除缓存后问题依然没有解决。

慢慢的才发现主题中的img文件夹是放到static文件夹下的。如果程序在工作目录下没有找到avatar.png，就会在主题下的相应目录下查找avatar.png，而由于我在工作目录下将img文件夹放错了位置，所以博客中的头像一直来自于主题下的static/img/avatar.png。

因此我在工作目录下的static目录下创建img文件夹，并将avatar.png文件放入其中，问题解决。

如果要修改favicon.ico方式也是一样的。