---
title: 用C创建记录型文件
author: team317
Date: 2021-04-30
categories:  
  - "C语言笔记"
tags:  
  - "C"
notoc: true
---
**问题概述**

简单的创建一个记录型文件

文件分为流式文件和记录型文件。流式文件中的数据没有组织结构，可以认为是一长串的字符；而记录型文件是有结构的，比如我们用的excel，可以认为每一行是一条记录，每条记录中可以有不同类型的数据，如字符型的姓名，浮点型的分数，这些数据组成了一个同学的成绩记录。<!--more-->
这次需要做的就是简单的做个实践，创建一个记录型文件用于记录学生信息，每条记录包含学生姓名，学生专业课程，学生学号。

### 代码部分
```C
#include<stdio.h>
#include<stdlib.h>
#define N 3
typedef struct{
	int number;
	char name[30];
	char major[30];
}Student_info;
// 输入学生的学号，打印其中的信息
void readInfo(int index){
	FILE *fp = fopen("students.info","r");
	if(fp == NULL){
		printf("文件打开失败！");
		exit(0);
	}
	fseek(fp, index*sizeof(Student_info), SEEK_SET);
	Student_info stu;
	fread(&stu, sizeof(Student_info), 1, fp);
	printf("学生编号：%d\n",stu.number);
	printf("学生姓名：%s\n",stu.name);
	printf("学生专业：%s\n",stu.major);
	fclose(fp);
}

int main(){
	// 
	FILE *fp = fopen("students.info", "w");
	if(fp==NULL){
		printf("打开文件失败！");
		exit(0);
	}
	Student_info student[N];
	for(int i=0; i<N; i++){
		student[i].number = i;
		scanf("%s",student[i].name);
		scanf("%s",student[i].major);
	}
	// 将输入的信息写入文件中
	fwrite(student, sizeof(Student_info),N,fp);
	fclose(fp);
	readInfo(0);	// 0号学生信息
	return 0;
}

```
执行之后生成student.info文件，这个后缀名可以自己定，甚至可以写成.txt，但是这个文件的读取需要自己写相关的代码才能正确获取里面的信息，用其他软件打开得到的可能会是一堆乱码，比如用记事本打开，由于记事本会将里面的数据处理成字符串，所以每个字节记事本都会尝试着转成对应的字符字形码，有些字节中存放的数据不是字符，处理出来就成了乱码。
### 存在的问题
这里只能输入ascii字符，不能输入中文字符。