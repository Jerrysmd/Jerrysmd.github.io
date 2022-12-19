# SpringMVC Introduction


Spring MVC is a module in the Spring framework that helps you build web applications. It is a framework that helps you build web applications in a clean and modular way, by providing a structure for request handling and a model-view-controller design pattern.

<!--more-->

## SpringMVC

### 对比 Servlet

> 对比 SpringMVC 和 Servlet，实现相同的功能。
>
> 实现对 User 模块增删改查的模拟操作。 

**Servlet 实现** 

+ com.jerry.servlet.**UserSaveServlet**.java:

  ```java
  package com.jerry.servlet;
  
  import ...;
  
  @WebServlet("/user/save")
  public class UserSaveServlet extends HttpServlet{
      @Override
      protected void doGet(HttpServletRequest req, HeepServletResponse resp) throws ServletException, IOException{
          String name = req.getParameter("name");
          println("servlet save name：" + name);
          resp.setContenType("text/json;charset=utf-8");
          PrintWriter pw = resp.getWriter();
          pw.write("{'module':'servlet save'}");
      }
      @Override
      protected void doPost(HttpServletRequest req, HeepServletResponse resp) throws ServletException, IOException{
          this.doGet(req,resp);
      }
  }
  ```

+ com.jerry.servlet.**UserSelectServlet**.java: 和 Save 功能类似实现方式

+ com.jerry.servlet.**UserUpdateServlet**.java: 和 Save 功能类似实现方式

+ com.jerry.servlet.**UserDeleteServlet**.java: 和 Save 功能类似实现方式

**SpringMVC 实现** 

+ com.jerry.springmvc.UserController.java:

  ```java
  package com.jerry.springmvc;
  
  import ...;
  
  @Controller
  public class UserController{
      @RequestMapping("/save")
      @ResponseBody
      public String save(String name){
          println("springmvc save name：" + name);
      }
      @RequestMapping("/select")
      @ResponseBody
      public String select(String name){
          println("springmvc select name：" + name);
      }
      @RequestMapping("/update")
      @ResponseBody
      public String update(String name){
          println("springmvc update name：" + name);
      }
      @RequestMapping("/delete")
      @ResponseBody
      public String delete(String name){
          println("springmvc delete name：" + name);
      }
  }
  ```

### 概述

+ SpringMVC 与 Servlet 技术功能等同，都属于 web 层开发技术
+ 优点
  + 使用简单，相比 Servlet 开发便捷
  + 灵活性强

