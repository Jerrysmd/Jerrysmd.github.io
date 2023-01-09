---
title: "Stock Monitoring and Notification Project"
# subtitle: ""
date: 2022-11-14T17:46:58+08:00
# lastmod: 2023-01-06T17:46:58+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Python", "Pandas"]
categories: ["Technology"]

# featuredImage: ""
# featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
# twemoji: false
# lightgallery: true
# ruby: true
# fraction: true
# fontawesome: true
# linkToMarkdown: true
# rssFullText: false

# toc:
#   enable: true
#   auto: true
# code:
#   copy: true
#   maxShownLines: 50
# math:
#   enable: false
#   # ...
# mapbox:
#   # ...
# share:
#   enable: true
#   # ...
# comment:
#   enable: true
#   # ...
# library:
#   css:
#     # someCSS = "some.css"
#     # located in "assets/"
#     # Or
#     # someCSS = "https://cdn.example.com/some.css"
#   js:
#     # someJS = "some.js"
#     # located in "assets/"
#     # Or
#     # someJS = "https://cdn.example.com/some.js"
# seo:
#   images: []

# admonition:
# {{< admonition tip>}}{{< /admonition >}}
# note abstract info tip success question warning failure danger bug example quote
# mermaid:
# {{< mermaid >}}{{< /mermaid >}}
---

The system will be flexible and allow users to specify their own set of rules for price movements and triggers for notifications. This is a useful tool for anyone interested in keeping track of their investments and making informed decisions in the stock market.

<!--more-->

## Introduction

In this project, we will be developing functions to retrieve stock data from Tencent and Sina using the Python programming language. The functions will be able to retrieve both daily and minute-level data, and will allow users to specify the stock code, time range, and frequency of the data.

## Design

### Tencent

For the Tencent functions, we will be using the `requests` library to make HTTP requests to the Tencent stock data API. The API will return the stock data in JSON format, which we will then parse and convert into a Pandas dataframe for easier manipulation.

The `get_price_day_tx` function will be used to retrieve daily data, while the `get_price_min_tx` function will be used to retrieve minute-level data. Users will be able to specify the stock code, end date (optional), number of periods to retrieve, and the frequency of the data (e.g. daily, weekly, monthly).

### Sina

For the Sina function, we will be using the `pandas_datareader` library to retrieve stock data from the Sina API. The `get_price_sina` function will allow users to specify the stock code, start and end dates, and the frequency of the data.

## Implementation

The Tencent functions will follow the steps outlined below:

1. Define the function and parse the input parameters.
2. Make the HTTP request to the Tencent API using the `requests` library.
3. Parse the JSON response and extract the relevant data.
4. Convert the data into a Pandas dataframe.
5. Return the dataframe to the user.

The Sina function will follow these steps:

1. Define the function and parse the input parameters.
2. Use the `pandas_datareader` library to retrieve the stock data from the Sina API.
3. Return the data to the user.

## Code

+ 使用 requests 从接口获取数据
+ 使用 pandas 将数据转化成表格

```python
import datetime
import json
import requests
import pandas as pd

# 腾讯日线
def get_price_day_tx(code, end_date='', count=10, frequency='1d'):  # 日线获取
    unit = 'week' if frequency in '1w' else 'month' if frequency in '1M' else 'day'  # 判断日线，周线，月线
    if end_date:  end_date = end_date.strftime('%Y-%m-%d') if isinstance(end_date, datetime.date) else \
    end_date.split(' ')[0]
    end_date = '' if end_date == datetime.datetime.now().strftime('%Y-%m-%d') else end_date  # 如果日期今天就变成空
    URL = f'http://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param={code},{unit},,{end_date},{count},qfq'
    st = json.loads(requests.get(URL).content);
    ms = 'qfq' + unit;
    stk = st['data'][code]
    buf = stk[ms] if ms in stk else stk[unit]  # 指数返回不是qfqday,是day
    df = pd.DataFrame(buf, columns=['time', 'open', 'close', 'high', 'low', 'volume'], dtype='float')
    df.time = pd.to_datetime(df.time);
    df.set_index(['time'], inplace=True);
    df.index.name = ''  # 处理索引
    return df


# 腾讯分钟线
def get_price_min_tx(code, end_date=None, count=10, frequency='1d'):  # 分钟线获取
    ts = int(frequency[:-1]) if frequency[:-1].isdigit() else 1  # 解析K线周期数
    if end_date: end_date = end_date.strftime('%Y-%m-%d') if isinstance(end_date, datetime.date) else \
    end_date.split(' ')[0]
    URL = f'http://ifzq.gtimg.cn/appstock/app/kline/mkline?param={code},m{ts},,{count}'
    st = json.loads(requests.get(URL).content);
    buf = st['data'][code]['m' + str(ts)]
    df = pd.DataFrame(buf, columns=['time', 'open', 'close', 'high', 'low', 'volume', 'n1', 'n2'])
    df = df[['time', 'open', 'close', 'high', 'low', 'volume']]
    df[['open', 'close', 'high', 'low', 'volume']] = df[['open', 'close', 'high', 'low', 'volume']].astype('float')
    df.time = pd.to_datetime(df.time);
    df.set_index(['time'], inplace=True);
    df.index.name = ''  # 处理索引
    df['close'][-1] = float(st['data'][code]['qt'][code][3])  # 最新基金数据是3位的
    return df


# sina新浪全周期获取函数，分钟线 5m,15m,30m,60m  日线1d=240m   周线1w=1200m  1月=7200m
def get_price_sina(code, end_date='', count=10, frequency='60m'):  # 新浪全周期获取函数
    frequency = frequency.replace('1d', '240m').replace('1w', '1200m').replace('1M', '7200m');
    mcount = count
    ts = int(frequency[:-1]) if frequency[:-1].isdigit() else 1  # 解析K线周期数
    if (end_date != '') & (frequency in ['240m', '1200m', '7200m']):
        end_date = pd.to_datetime(end_date) if not isinstance(end_date, datetime.date) else end_date  # 转换成datetime
        unit = 4 if frequency == '1200m' else 29 if frequency == '7200m' else 1  # 4,29多几个数据不影响速度
        count = count + (datetime.datetime.now() - end_date).days // unit  # 结束时间到今天有多少天自然日(肯定 >交易日)
        # print(code,end_date,count)
    URL = f'http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol={code}&scale={ts}&ma=5&datalen={count}'
    dstr = json.loads(requests.get(URL).content);
    # df=pd.DataFrame(dstr,columns=['day','open','high','low','close','volume'],dtype='float')
    df = pd.DataFrame(dstr, columns=['day', 'open', 'high', 'low', 'close', 'volume'])
    df['open'] = df['open'].astype(float);
    df['high'] = df['high'].astype(float);  # 转换数据类型
    df['low'] = df['low'].astype(float);
    df['close'] = df['close'].astype(float);
    df['volume'] = df['volume'].astype(float)
    df.day = pd.to_datetime(df.day);
    df.set_index(['day'], inplace=True);
    df.index.name = ''  # 处理索引
    if (end_date != '') & (frequency in ['240m', '1200m', '7200m']): return df[df.index <= end_date][
                                                                            -mcount:]  # 日线带结束时间先返回
    return df


def get_price(code, end_date='', count=10, frequency='1d', fields=[]):  # 对外暴露只有唯一函数，这样对用户才是最友好的
    xcode = code.replace('.XSHG', '').replace('.XSHE', '')  # 证券代码编码兼容处理
    xcode = 'sh' + xcode if ('XSHG' in code) else 'sz' + xcode if ('XSHE' in code) else code

    if frequency in ['1d', '1w', '1M']:  # 1d日线  1w周线  1M月线
        try:
            return get_price_sina(xcode, end_date=end_date, count=count, frequency=frequency)  # 主力
        except:
            return get_price_day_tx(xcode, end_date=end_date, count=count,
                                    frequency=frequency)  # 备用

    if frequency in ['1m', '5m', '15m', '30m', '60m']:  # 分钟线 ,1m只有腾讯接口  5分钟5m   60分钟60m
        if frequency in '1m': return get_price_min_tx(xcode, end_date=end_date, count=count, frequency=frequency)
        try:
            return get_price_sina(xcode, end_date=end_date, count=count, frequency=frequency)  # 主力
        except:
            return get_price_min_tx(xcode, end_date=end_date, count=count, frequency=frequency)  # 备用
```

+ 监控 2500 日均线和当天股票情况
+ 满足判断条件后使用 smtplib 发送提示邮件 

```python
from email.header import Header
from email.mime.text import MIMEText

from Ashare import *
import smtplib
import os


def send_email(body):
    smtp_mail = os.environ.get('SMTP_MAIL')
    smtp_token = os.environ.get('SMTP_TOKEN')

    # 设置发件人和收件人的邮箱地址
    sender = smtp_mail
    recipient = smtp_mail

    # 设置邮件主题
    subject = "Github Actions: stock-spy Repository Remind"

    msg = MIMEText(body, "plain", "utf-8")
    msg["Subject"] = Header(subject, "utf-8")
    msg["from"] = sender
    msg["to"] = recipient

    # 连接到SMTP服务器
    server = smtplib.SMTP("smtp.qq.com")

    # 登录到SMTP服务器
    status, response = server.login(smtp_mail, smtp_token)

    if status == 235:
        print("SMTP 登录成功")
        if body != '':
            # 发送邮件
            server.sendmail(sender, recipient, msg.as_string())
            print("邮件已发送")
        else:
            print("无需发送邮件")
    else:
        print("SMTP 登录失败")

    # 关闭连接
    server.quit()


if __name__ == '__main__':
    dfTenYears = get_price('sh000001', frequency='1d', count=2500)

    lowLine = dfTenYears['close'].mean()
    highLine = lowLine + 470

    dfOneDay = get_price('sh000001', frequency='1d', count=1)

    lowPoint = dfOneDay['low'].mean()
    highPoint = dfOneDay['high'].mean()

    body = f"当前高水位是：{highLine}\n" \
           f"当前收盘价是：{dfOneDay['close'].mean()}\n" \
           f"当前低水位是：{lowLine}"

    print(body)

    if lowPoint < lowLine:
        send_email(f"当前最低点是：{lowPoint}\n"
                   f"当前低水位是：{lowLine}\n"
                   f"该买了")
    elif highPoint > highLine:
        send_email(f"当前最高点是：{highPoint}\n"
                   f"当前高水位是：{highLine}\n"
                   f"该卖了")
    else:
        send_email('')
```

+ 设置 Github Actions 每天运行脚本

```yaml
name: Python application

on:
  schedule:
    - cron: '0 8 * * *'
  workflow_dispatch:

permissions:
  contents: read

jobs:
  run_python_script:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python 3.10
      uses: actions/setup-python@v3
      with:
        python-version: "3.10"
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install flake8 pytest
        python -m pip install requests pandas
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
    - name: Set Environment Variables
      run: |
        echo "SMTP_MAIL=${{ secrets.SMTP_MAIL }}" >> $GITHUB_ENV
        echo "SMTP_TOKEN=${{ secrets.SMTP_TOKEN }}" >> $GITHUB_ENV
    - name: Run Python script
      run: |
        python main.py
```

