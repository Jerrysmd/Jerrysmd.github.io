---
title: "FRM Part Ⅰ: Foundations of Risk Management"
# subtitle: ""
date: 2023-05-04T11:53:59+08:00
# lastmod: 2023-05-04T11:53:59+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["FRM", "Finance"]
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
code:
  copy: true
  maxShownLines: 0
math:
  enable: true
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

The Fundamentals of Risk Management is Chapter 1 of Part 1 for the FRM exam. This chapter primarily covers the foundational knowledge, theories and best practices related to the subject of risk management.

<!--more-->

## Basic Sense of Risks and Management
### What Is Risk?

+ **Possibility of the bad things that might happen:**
  + It exists everywhere and anytime,we will focus on the financial world.
  + But it is not always a bad thing
    + **Good risk**: Risks that have a **positive expected payoff** on a stand-alone basis.
    + **Bad risk**: Risks that can be **expected to destroy value** on a stand alone basis.
    + Banks and other financial institutions c**annot succeed without taking risks.**

### What Is Risk Management?

+ **Risk management**: how firms actively select the types and levels of risks that are appropriate for them to take.
+ **Risk management and risk taking aren't opposites, but two sides of the same coin.**
  + Together they drive all our modern economies.
  + It's all about making forward-looking choices about risk in relation to reward.

### Is Risk Management Useful?

+ **Challenges for risk management** 
  + Fail to prevent market disruptions or **accounting scandals**
  + **Derivative** markets make it easier to take on large amount of risk.
  + Sophisticated financial engineering leads to the violent implosion of-firms.
  + Only **transfer** risks to other firms
    + Risk management is a zero-sum game
  + Work to the short-term benefit.

### Risk Management Process

1. Identify the risk
2. Analyze and measure risk
3. Assess the effects of all risk, and balance between risk and reward
4. Manage the risk using different kind of tools

![image-20230810174002706](image-20230810174002706.png " ")

![image-20230810173930525](image-20230810173930525.png " ")

### Identify the risk

+ There are things we know that we know.
+ There are known unknowns... But there are also unknown unknowns.

![image-20230810174750161](image-20230810174750161.png " ")

### Analyze and measure risk

+ **Quantitative Risk Measures**
  + VaR(Value at risk)
    + Developed by Dennis Weatherstone,CEO of J.P. Morgan
    + VaR uses the loss distribution associated with a position or portfolio to estimate losses at a given level of likelihood (or confidence).
      + E.g. a one day 99% **confidence level**（置信水平） VaR of USD 1 million
+ **Qualitative Risk Measures**
  + Scenario analysis
  + Stress testing

![image-20230811113053307](image-20230811113053307.png " ")

### Tail Risk

+ Some credit portfolios, however exhibit a much moreextreme variance in their losses over `longer intervals of time`(e.g., a decade). 
+ **From the crisis lesson, we focus on the tail risk beyond confidence level which cannot be explained by VaR.**
  + *Extreme value theory*(EVT)（FRM Part2 内容） focuses on tail distribution to understand the black swans 
  + *Expected shortfall*（指所有极端值的平均数） is the EL of tail distribution

### Expected Loss(EL)

+ EL is the average loss expected to incur from a position or a portfolio. It can be estimated by historical data of a period of time. 
  + It can be treated as a predictable expense rather than a risk or
    uncertainty
+  In the case of the credit risk of a loan: 
  + EL=EAD x LGD x PD (part1 估值与风险建模 会重讲)
    + PD: Probability of default 
    + EAD: Exposure amount at default 
    + LGD: Loss given default
+ EL is often **priced into the product directly.**

### Unexpected Loss(UL)

+ On a bad day, losses can range above the expected level. **Unexpected loss is the surprising loss that above the EL in bad days.**
  + Value at risk (VaR) uses the loss distribution to estimate losses at a given level of likelihood(confidence). 
  + UL= VaR - EL (Unexpected loss is the surprising loss that above the EL in bad days)
  + **Economic capital**(usually called risk capital) is the amount of liquid -
    capital used to cover unexpected loss. 
+ **Correlation risk**,where unfavorable events happen together, will drive potential losses to unexpected levels. 
+ In practice, **concentration** makes the probability of multiple losses high for a portfolio. As a result, we need more capital to cover the UL.

### Balance Between Risk and Reward 

+ There is a natural trade-off between risk and reward: the more risk takes, the more potential reward is earned. 
+ However, there are challenges. 
  1. Conflicts between EL and UL, can be solved by RAROC
     + Risk adjusted return on capital(RAROC)=after-tax risk-adjusted expected return(EL is subtracted)/economic capital
  2. Correlation between risk factors is changing
  3. Conflicts of interests among different units, can be solved by three lines of defense
     + business line that generates,owns, and manages risk;
     + risk managers implement day-to-day oversight;
     + periodic independent oversight and assurance, such as internal audit
