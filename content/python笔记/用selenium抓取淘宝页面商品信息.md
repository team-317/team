---
title: 用selenium抓取淘宝页面商品信息
author: team317
Date: 2021-05-03
categories:  
  - "python笔记"
tags:  
  - "爬虫"
  - "python"
---

**问题概述**

使用selenium登录淘宝并抓取关键字"iPad"对应页面的商品信息。

页面的抓取使用requests应该也能做到，这次的话使用selenium获取每一页的信息，然后用pyquery对页面信息进行处理。
<!--more-->
**环境**

版本：python3.8

所需的关键库：selenium、pyquery

需要用到的软件：`chromedriver`和`chrome`

### 登录淘宝

如果要用requests访问登录后的页面，则在请求头中加入cookies信息即可，cookies信息可以从浏览器控制台通过`document.cookie`获得。但使用selenium的话要更麻烦一些，因为如果要想selenium模拟的浏览器中加入cookie，得一条一条cookie加入，上图做个对比：

![在这里插入图片描述](https://img-blog.csdnimg.cn/2021050319134593.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)


左下角的是一连串的cookies，等号左边是cookie的名称，等号右边是cookie的值；如果使用requests，则将这一连串的cookies加入到headers中即可。而右图中则是一条一条的cookie，每条cookie都有name、value、domain等几个字段，如果你使用selenium，则需要将一条cookie处理成`{"domain": ".taobao.com", "expiry": 1635516014, "httpOnly": false, "name": "l", "path": "/", "secure": false, "value": "eBj61Tjejomnbu7SBOfanurza77OSIRYYuPzaNbMiOCPO_CB5UlPW61E8nY6C3Gch63JR3xIkQOzBeYBqQAonxvOvhLyCdMmn"}`的形式，然后使用add_cookie()将其加入到浏览器对象中。



这里参考了两条博客：

[selenium使用cookie实现免密登录](https://blog.csdn.net/a836586387/article/details/100100313)

[[selenium加载cookie报错问题：selenium.common.exceptions.InvalidCookieDomainException: Message: invalid cookie domain](https://www.cnblogs.com/deliaries/p/14121204.html)](https://www.cnblogs.com/deliaries/archive/2020/12/11/14121204.html)

根据博客一第一次访问淘宝搜索页面时可以先手动扫码登录，然后获取到页面的cookie，保存下来，后面就能通过这些cookies自动的爬取数据了。

代码如下：

```python
"""
Created on Sun May  2 15:12:44 2021

@author: Team317
"""

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.wait import WebDriverWait
from urllib.parse import quote
import json
import time
from pyquery import PyQuery as pq
import sys
from random import randint,random

def get_cookie():
    #手动获取cookies
    browser = webdriver.Chrome()
    wait = WebDriverWait(browser, 10)
    # 先访问登录页面
    login_url = 'https://login.taobao.com/member/login.jhtml?redirectURL=http%3A%2F%2Fs.taobao.com%2Fsearch%3Fq%3DiPad&uuid=6b5f203675de0dfb1d09899a2572b80b'
    browser.get(login_url)
    # 得到登录页面的cookie
    cookies = browser.get_cookies()
    
    # 访问搜索页面
    KEYWORD = 'iPad'
    url = 'https://s.taobao.com/search?q={keyword}'.format(keyword = KEYWORD)
    # 手动登录成功后输入Y继续
    ok = input("Are you ok?[Y/N]")
    # 输入N时退出程序
    if ok != 'Y':
        browser.close()
        sys.exit()
        
    browser.get(url)
    # 获取搜索页面的cookie
    cookie = browser.get_cookies()
    for cook in cookie:
        cookies.append(cook)
        
    # 保存cookies信息
    with open("taobao_cookies.txt","w") as file:
        file.write(json.dumps(cookies))
        
    # # 关闭浏览器
    # browser.close()
    
    return browser, wait
```



在taobao_cookies.txt文件中保存了网页的每条cookie，如下图，

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503191415353.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)


这是其中的三条，有了cookies，后面就更方便了。




### 商品搜索页面的访问

用selenium登录淘宝后通过控制底部的页面访问栏来跳转页面：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503191635512.png)



先向页面搜索框输入页面号，再模拟点击确定按钮，跳转到指定页面后即可抓取页面信息，代码如下：

```python
    
def load_cookie():
    browser = webdriver.Edge()
    # 每次跳转请求页面的等待时间为20秒，超出20秒时产生超时异常
    wait = WebDriverWait(browser, 10)
    # 读取cookies
    with open("taobao_cookies.txt") as file:
        cookies = json.loads(file.read())
        
    # 首先访问登录页面
    login_url = 'https://login.taobao.com/member/login.jhtml?redirectURL=http%3A%2F%2Fs.taobao.com%2Fsearch%3Fq%3DiPad&uuid=6b5f203675de0dfb1d09899a2572b80b'
    browser.get(login_url)
    
    # 然后加载cookies
    for cook in cookies:
        try:
            browser.add_cookie(cook)
        except:
            # 打印被舍弃的cookie
            print(cook)
            print("*********************")
    return browser, wait
    
# 访问第index个页面
def index_page(browser, wait, page, keyword):
    
    print("正在爬取第{page}页".format(page = page))
    try:
        # 访问搜索页面
        url = 'https://s.taobao.com/search?q={keyword}'.format(keyword = keyword)
        time.sleep(random()*10 + 2)
        browser.get(url)
        if page > 1:
            input = wait.until(
                EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > input')))
            submit = wait.until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > span.btn.J_Submit')))
            time.sleep(random()*10 + 2)
            input.clear()
            time.sleep(random()*10 + 2)
            input.send_keys(page)
            time.sleep(random()*10 + 2)
            submit.click()
        time.sleep(random()*10 + 2)
        # 等待页面被加载出来
        wait.until(
            EC.text_to_be_present_in_element((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > ul > li.item.active > span'),str(page)))
        wait.until(
            EC.presence_of_element_located((By.CSS_SELECTOR,'#mainsrp-itemlist > div > div > div')))
        time.sleep(random()*10 + 4)
        # 获取页面信息
        get_products(browser)
        print("第{page}页抓取完成".format(page=page))
    except TimeoutException:
        # 出现超时时不再继续，结束程序
        print('超时')
        browser.close()
        sys.exit()

def get_products(browser):
    html = browser.page_source
    doc = pq(html)
    items = doc('#mainsrp-itemlist > div > div > div:nth-child(1) > div').items()
    
    with open("products_info.txt", 'a+') as file:
        for item in items:
            product = {
                'image':item.find('.pic .img').attr('data-src'),
                'price':item.find('price').text(),
                'deal':item.find('.deal-cnt').text(),
                'title':item.find('.title').text(),
                'shop':item.find('.shop').text(),
                'location':item.find('.location').text()
            }
            # print(product)
            # print("************")
            info = json.dumps(product) + '\n'
            file.write(info)
    
        

if __name__ == '__main__':
    # 首次登录标志
    is_first = True
    if is_first == True:
        # 首次登录时，手动扫码淘宝，获取cookies
        browser,wait = get_cookie()
    else:
        # 如果之前登录过，则从文件中加载cookies
        browser,wait = load_cookie()
    
    # 之后自动化的抓取页面信息
    for i in range(1,10):
        index_page(browser, wait, i, 'iPad')
        
        # 等待几秒再访问，以防被察觉
        time.sleep(random()*10 + 10)
    
    browser.close()
```



### 应对反爬虫的一些尝试

在实验过程中，我的反复尝试被淘宝发现了，然后就弹出了下面这个验证框：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210503191520732.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0dvZE5vdEFNZW4=,size_16,color_FFFFFF,t_70)
关键是这个验证框是没法验证的，当你将滑块拖动到最右边之后依然停留在这个页面，可能是我的账号被记住了或者被封ip了，一段时间内不能再访问，使用代理进行访问会更安全一些。

为防止这一情况发生，我尝试着在每一次模拟操作之后等待一段时间再进行下一次操作，于是在代码中就多了很多的time.sleep()语句，并将等待的时间用random设置为随机数。遗憾的是，使用这样的方法依然会被发现。网站反爬虫的方式挺多的，我不清楚在这里触发网站的反爬虫机制的具体原因。

