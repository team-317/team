---
title: 用pymysql操作mysql
author: team317
Date: 2021-05-01
categories:  
  - "python笔记"
tags:  
  - "mysql"
  - "python"
---
在python中使用pymysql操作mysql数据库，代码和注释如下：
<!--more-->
```python [ ]
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 30 20:00:40 2021

@author: Team317
"""

import pymysql
'''
pymysql提供的功能已经能比较好的完成数据库操作任务了，
这里进一步将其简化，只需要提供数据，调用类中的函数就能完成任务，
省去了写sql语句的步骤，更具便捷
类中的每一个功能都可以拆分出来，根据需要可提取代码段
'''

class mysql():
## 初始化获得游标cursor，游标是关键
    def __init__(self,host,user,password,port,db=None):
        if db == None:
            self.db = pymysql.connect(host = host, user = user, password=password, port =port)
        else:
            self.db = pymysql.connect(host = host, user = user, password=password, port =port,db=db)
        # 数据库游标是必不可少的，就像文件指针一样
        self.cursor = self.db.cursor()
        # 下面的这些信息在create_a_db()中可能用得上
        self.host = host
        self.user = user
        self.password = password
        self.port = port
        
## 检查数据库版本        
    def check_version(self):
        self.cursor.execute('select version()')
        data = self.cursor.fetchone()
        print('DB version:',data)
        
## 创建数据库操作 
    # 创建一个数据库，名字为spiders
    def create_a_db(self,db):
        # connect中可以不传入db参数(数据库名称)
        self.cursor.execute("create database {db} default character set utf8".format(db=db))
        self.db = pymysql.connect(host = self.host, user = self.user, password=self.password, port = self.port, db=self.db)


## 创建表格操作
    # 在数据库中新建一个表，测试为students
    def create_a_table(self):
        # 需向connect中传入db参数，指明在哪个数据库中创建表格
        # 创建一个表格
        sql = 'create table if not exists students (id varchar(255) not null, name varchar(255) not null, \
                age int not null, primary key (id))'
        self.cursor.execute(sql)
    
## 插入操作
    # 向students中插入数据
    def add_info(self,db,id,user,age):
        sql = 'insert into students(id,name,age)values(%s,%s,%s)'
        try:
            self.cursor.execute(sql, (id,user,age))
            # 执行commit让数据同步到数据库，就像git一样
            self.db.commit()
        except:
            # 当失败时执行rollback当作没发生
            self.db.rollback()

## 插入操作增强版
    # 这个函数可以完成add_info的任务，并且具有更好的复用性
    def add_Info(self, data, table):
        # keys即为'id, name, age'
        keys = ', '.join(data.keys())
        # 当len(data)=3时，['%s']*len(data)即为['%s','%s','%s']
        values = ', '.join(['%s']*len(data))
        
        # 拼写出主键存在时更新，不存在时插入的sql语句
        # insert intostudents(id, name, age) values(%s, %s, %s) 
        sql = 'insert into {table}({keys}) values({values}) ' \
                .format(table=table,keys=keys,values=values)
        # on duplicate key updateid = %s,name = %s,age = %s
        update = 'on duplicate key update ' + ','.join(["{key} = %s".format(key=key) for key in data])
        sql += update   # 拼接sql
        
        try:
            self.cursor.execute(sql, tuple(data.values())*2)
            self.db.commit()
            print("sucess!")
        except:
            self.db.rollback()
            print("fail!")
        
## 删除操作         
    def delete_Info(self,table,condition):
        # 删除操作的sql语句
        sql = 'delete from {table} where {condition}'.format(table=table, condition = condition)
        
        try:
            self.cursor.execute(sql)
            self.db.commit()
        except:
            self.db.rollback()
## 查询操作
    def find_Info(self, table, condition):
        sql = 'select * from {table} where {condition}'.format(table=table,condition=condition)
        try:
            self.cursor.execute(sql)
            print('Count:',self.cursor.rowcount)
            row = self.cursor.fetchone()
            while row:
                print('Row:', row)
                row = self.cursor.fetchone()
        except:
            print('Error')
## 关闭操作
    def close(self):
        # 关闭数据库
        self.db.close()
        
    
if __name__ == '__main__':

    db = 'spiders'
    table = 'students'
    host = 'localhost'
    user = 'root'
    password = '1234'
    port = 3306
    SQL = mysql(host, user, password, port, db)
    
    data = {
        'id':'201200001',
        'name':'Bob',
        'age':21
    }
    SQL.add_Info(data, table)
    SQL.find_Info('students', 'age=21')
  ```
 