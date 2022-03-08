---
title: Ubuntu命令简记
author: team317
Date: 2022-03-08
categories:  
  - "编程散记"
tags:  
  - "linux"
---
以下是初学Ubuntu命令的一次学习记录
+ `history`    显示在该终端使用过的所有命令；
+ `history |grep sudo*`   显示在该终端中使用过且包含字符“sudo”的所有命令；<!--more-->
+ `!!`  获得上一条指令，可和sudo搭配；
+ `cd -`  进入上一次所在目录，相当于windows文件资源管理器左上方的‘←’；
+ `mkdir`  创建文件夹；
+ `vi`  编辑文件，如果没有文件则创建该文件；
+ `pwd`  显示当前文件路径
+ `apt`  集合了apt-update、apt-cache、apt-get等命令的功能；
+ `find -name lib*`  寻找并显示含有"lib"字符串的文件
+ `chmod`  修改文件的权限，如chmod  777 test1.cpp；（由vi创建的文件用户似乎不具备读写权限）
+ `ls -la`  列出当前文件夹下各文件和文件夹的权限；
+ `ln -s source target`  source和target是两个文件（绝对路径），ln的作用是将target文件软链接到source文件上；
+ `wget`  根据下载链接下载文件；
+ `unzip`  解压文件；

文件的权限：
`drwxrwxrwx`  
+ d代表目录，如果是文件则为`-`

后面有三个重复的'rwx'分别表示超级用户、普通用户、程序用户对于文件或文件夹的权限；
+ r为读权限； 代号为4
+ w为写权限；代号为2
+ x为打开权限；代号为1

可用`chmod`修改文件/文件夹的权限；
如`chmod 555 test1.cpp `表示分别赋予超级用户、普通用户、程序用户对于test1.cpp的4+1=5权限，4+1即`4(r)+1(x)`表示读取和打开权限；

关于vi的操作：
三种模式切换：
+ Esc键切换到命令行模式
	`ctrl+f` 向下翻屏；
	`ctrl+b` 向上翻屏；
+ `shift+:`切换到末行模式
	`:q!` 强制退出；
	`w` 保存；
	`wq` 保存并退出；
+  按`i`进入文本输入模式


在windows的应用商店上下了Ubuntu20.04 LTS，并通过软链接（和桌面快捷方式相似）转移到了单独的E盘，下午结合之前接触的内容好好探索了一下Ubuntu，更熟悉了一些。