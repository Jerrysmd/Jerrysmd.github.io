# Financial Risk Manager Introduction


The Financial Risk Manager (FRM) Certification is the true standard for educational excellence in risk management and a gateway to achieving new career heights in the risk profession.

<!--more-->

## Key Concepts

### Interest Rates

#### Required Rate of Return

  - Required rate of return / 要求回报率 / yield
  - Influenced by the `supply and demand of funds` in the market.
  - Represents the return that investors and savers need to convince them to willingly lend their money.
  - Typically associated with a specific investment.
  - Example: If I deposit my money in a bank, what would the interest rate be?
    - In this case:
    - Interest rate = Required Rate of Return = Real Risk-free Return (真实无风险收益率) + Inflation Rate (通货膨胀收益率)
  - Breaking down the required rate of return:
    - Nominal risk-free rate = real risk-free rate + expected inflation rate.
    - Required interest rate on a security = nominal risk-free rate + default risk premium + liquidity risk premium + maturity risk premium.

#### Discount Rate

  - Discount rate / 折现率
  - This is the interest rate used to `discount future payments`.
  - It is often used interchangeably with the term "interest rate".
  - Depending on the situation, "interest rate" can have different names:
    - Example 1: I deposit \$100 in a bank for one year and receive a 10% interest rate. After one year, I have 110.
      - In this scenario, the 10% interest rate is referred to as the 10% Required Rate of Return.
    - Example 2: I want to have \$10 after one year. If the interest rate is 10%, how much should I deposit in the bank? Using the formula (x+10)/(1+10%) = x, we find x = 100.
      - In this scenario, the 10% interest rate is referred to as the 10% Discount Rate.

#### Opportunity Cost

  - Opportunity cost / 机会成本
  - This can be seen as a type of interest rate. It represents the value that investors give up when they choose a particular course of action.

### Basic Calculation

#### Future Value (FV):

  + Amount to which investment grows after one or more compounding periods

#### Present Value (PV):

  + Current value of some future cash flow

  + If interests are compounded m times per year, and `invest 1 year`: 

    $$
    FV=PV(1+\frac{r}{m})^m
    $$

  + If interests are compounded m times per year, and `invest n years`:
    $$
    FV=PV(1+\frac{r}{m})^{mn}
    $$
    Where: 
  
    `m` is the compounding frequency;
  
    `r` is the nominal / quoted annual interest rate

#### Simple Interest

  + Simple Interest / 单利
  
  + Interest is compounded annually at 10% per annum
  
  + ```mermaid
    sequenceDiagram
    	Note over Start Deposit: PV = 100$
        Start Deposit->>First Year End: 10%
        Note over First Year End: 100+100*10%
        First Year End->>Second Year End: 10%
        Note over Second Year End: FV = 100+100*10%*2
    ```
  
  + {{< mermaid >}}
  
    sequenceDiagram
    	Note over Start Deposit: PV = 100$
        Start Deposit->>First Year End: 10%
        Note over First Year End: 100+100*10%
        First Year End->>Second Year End: 10%
        Note over Second Year End: FV = 100+100*10%*2
  
    {{< /mermaid >}}

#### Compound Interest

  + Compound Interest / 利滚利

  + Interest is compounded annually at 10% per annum

  + ```mermaid
    sequenceDiagram
    	Note over Start Deposit: PV = 100$
        Start Deposit->>First Year End: 10%
        Note over First Year End: 100*(1+10%)
        First Year End->>Second Year End: 10%
        Note over Second Year End: FV = 100*(1+10%)^2
    ```

  + {{< mermaid >}}

    sequenceDiagram
    	Note over Start Deposit: PV = 100$
        Start Deposit->>First Year End: 10%
        Note over First Year End: 100*(1+10%)
        First Year End->>Second Year End: 10%
        Note over Second Year End: FV = 100*(1+10%)^2

    {{< /mermaid >}}

#### Continuously Compounding:

  + Interest is compounded `m` times per year at an annual rate of `r`%, then after `n` years

$$
  FV=PV\lim_{m\rightarrow\infty}(1+\frac{r}{m})^{mn}=PVe^{nr}
$$

#### Annuity

  + Annuity / 年金
  + Annuity is a stream of `equal cash flows` that occurs at `equal intervals` over a given period
  + Classify:
    + Annuity due - 先付年金(年初支付)
    + Ordinary annuity - 后付年金(年末支付)

## Framework of FRM Program

## Things To Know About FRM Exam



