---
title: "Comprehensive Guide to Integrating Swagger with Spring"
# subtitle: ""
date: 2023-09-25T11:46:06+08:00
# lastmod: 2023-09-25T11:46:06+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Java", "Spring"]
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

In the development process, the interface documentation is a crucial part. It not only facilitates developers in viewing and understanding the functionality and parameters of the interfaces but also helps in coordinating the work between the front-end and back-end development, thereby improving development efficiency. This article will introduce how to use Swagger in Spring Boot to automatically generate interface documentation.

<!--more-->

## About Swagger

Swagger is a specification and toolset for RESTful interface documentation. Its goal is to standardize the format and conventions of RESTful interface documentation. In the development process, interface documentation plays a crucial role. It not only facilitates developers in viewing and understanding the functionality and parameters of the interfaces but also helps in coordinating the work between the front-end and back-end development, thereby improving development efficiency. In Spring Boot, we can achieve automatic generation of interface documentation by integrating Swagger. Swagger uses annotations to describe interfaces and generates interface documentation based on these annotations.

## Usage of Swagger

1. Writing Interfaces

When writing interfaces, we need to use Swagger annotations to describe the interface information. Some commonly used annotations include:

- @Api: Used to describe the class or interface of the interface.
- @ApiOperation: Used to describe the method of the interface.
- @ApiParam: Used to describe the parameters of the interface.
- @ApiModel: Used to describe the data model.
- @ApiModelProperty: Used to describe the properties of the data model.

For example, let's write a simple interface:

```java
@RestController
@Api(tags = "User Interface")
public class UserController {

    @GetMapping("/user/{id}")
    @ApiOperation(value = "Get user information by ID")
    public User getUserById(@ApiParam(value = "User ID", required = true) @PathVariable Long id) {
        // Query user information by ID
    }
}
```

In the above code, `@Api` indicates that the class is a user interface, `@ApiOperation` indicates that the method is an interface for getting user information, `@ApiParam` indicates that the parameter is the user ID, and `@PathVariable` indicates that the parameter is a path parameter.

2. Enabling Swagger

In Spring Boot, we can enable Swagger by adding the necessary dependencies. We can add the following dependencies to the `pom.xml` file:

```xml
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.9.2</version>
</dependency>
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.9.2</version>
</dependency>
```

In Spring Boot, we also need to add a configuration class to configure Swagger. Here is an example of a configuration class:

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.example.demo.controller"))
                .paths(PathSelectors.any())
                .build()
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Interface Documentation")
                .description("Interface Documentation")
                .version("1.0.0")
                .build();
    }
}
```

In the above code, `@Configuration` indicates that the class is a configuration class, and `@EnableSwagger2` enables Swagger. In the `api()` method, we configure the package path to scan using the `select()` method, configure the interface access paths using the `paths()` method, and configure the relevant information of the interface documentation using the `apiInfo()` method.

3. Viewing Interface Documentation

After starting the Spring Boot application, we can access http://localhost:8080/swagger-ui.html in a browser to view the interface documentation. In the Swagger UI page, we can see all the interface information, including the interface name, request method, request path, request parameters, response parameters, and so on.

## Advanced Usage of Swagger

1. Describing Data Models

We can use the @ApiModel and @ApiModelProperty annotations to describe data models and properties. For example, let's create a User class and use the @ApiModel and @ApiModelProperty annotations on the class to describe the data model:

```java
@ApiModel(description = "User information")
public class User {

    @ApiModelProperty(value = "User ID", example = "1")
    private Long id;

    @ApiModelProperty(value = "Username", example = "John Doe")
    private String username;

    @ApiModelProperty(value = "Password", example = "password123")
    private String password;

    // Getter and setter methods omitted
}
```

In the above code, @ApiModel indicates that the class is a data model, and @ApiModelProperty indicates that the property is a property of the data model. The value attribute represents the description of the property, and the example attribute represents the example value of the property.

2. Describing Enum Types

We can use the @ApiModel and @ApiModelProperty annotations to describe enum types. For example, let's create a Gender enum type and use the @ApiModelProperty annotation on the enum values to describe them:

```java
@ApiModel(description = "Gender")
public enum Gender {

    @ApiModelProperty(value = "Male")
    MALE,

    @ApiModelProperty(value = "Female")
    FEMALE;
}
```

In the above code, @ApiModel indicates that the enum type is a description of gender, and @ApiModelProperty indicates that the enum value describes either male or female.

3. Describing Response Parameters

We can use the @ApiResponses and @ApiResponse annotations to describe the response parameters of an interface. For example, let's create a getUserById() method and use the @ApiResponses and @ApiResponse annotations on the method to describe the response parameters:

```java
@GetMapping("/user/{id}")
@ApiOperation(value = "Get user information by ID")
@ApiResponses({
        @ApiResponse(code = 200, message = "Request successful", response = User.class),
        @ApiResponse(code = 404, message = "User not found")
})
public User getUserById(@ApiParam(value = "User ID", required = true) @PathVariable Long id) {
    // Query user information by ID
}
```

In the above code, @ApiResponses indicates the response parameters of the method, and @ApiResponse describes the response parameter. The code attribute represents the response code, the message attribute represents the response message, and the response attribute represents the data model of the response.

## Configuring Parameters

1. Configuring Global Parameters

We can use the `globalOperationParameters()` method in the configuration class to configure global parameters. For example, we can configure a global "Authorization" parameter for authentication:

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.example.demo.controller"))
                .paths(PathSelectors.any())
                .build()
                .globalOperationParameters(Arrays.asList(
                        new ParameterBuilder()
                                .name("Authorization")
                                .description("Authorization")
                                .modelRef(new ModelRef("string"))
                                .parameterType("header")
                                .required(false)
                                .build()
                ))
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("API Documentation")
                .description("API Documentation")
                .version("1.0.0")
                .build();
    }

}
```

In the above code, we use the `globalOperationParameters()` method to configure a global "Authorization" parameter for authentication.

2. Configuring Security Schemes

We can use the `securitySchemes()` method in the configuration class to configure security schemes. For example, we can configure a Bearer Token security scheme:

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.example.demo.controller"))
                .paths(PathSelectors.any())
                .build()
                .securitySchemes(Arrays.asList(
                        new ApiKey("Bearer", "Authorization", "header")
                ))
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("API Documentation")
                .description("API Documentation")
                .version("1.0.0")
                .build();
    }

}
```

In the above code, we use the `securitySchemes()` method to configure a Bearer Token security scheme.

3. Configuring Security Contexts

We can use the `securityContexts()` method in the configuration class to configure security contexts. For example, we can configure a security context to display an authentication button in Swagger UI:

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.example.demo.controller"))
                .paths(PathSelectors.any())
                .build()
                .securitySchemes(Arrays.asList(
                        new ApiKey("Bearer", "Authorization", "header")
                ))
                .securityContexts(Collections.singletonList(
                        SecurityContext.builder()
                                .securityReferences(Collections.singletonList(
                                        new SecurityReference("Bearer", new AuthorizationScope[0])
                                ))
                                .build()
                ))
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("API Documentation")
                .description("API Documentation")
                .version("1.0.0")
                .build();
    }

}
```

In the above code, we use the `securityContexts()` method to configure a security context to display an authentication button in Swagger UI.

4. Ignoring Parameters

In some cases, certain parameters in an interface may contain sensitive information that we don't want to display in the API documentation. We can use the `@ApiIgnore` annotation to ignore these parameters. For example, we can use the `@ApiIgnore` annotation on the password parameter in the User class to ignore it:

```java
@ApiModel(description = "User information")
public class User {

    @ApiModelProperty(value = "User ID", example = "1")
    private Long id;

    @ApiModelProperty(value = "Username", example = "John Doe")
    private String username;

    @ApiModelProperty(hidden = true)
    @ApiIgnore
    private String password;

    // Getter and setter methods omitted
}
```

In the above code, `@ApiModelProperty(hidden = true)` indicates that the parameter is hidden, and `@ApiIgnore` indicates that the parameter should be ignored.

## Summary

By integrating Swagger, we can easily generate API documentation, making the collaboration between frontend and backend development more efficient. When using Swagger, it's important to keep the following points in mind:

- Use annotations to describe API information, including API names, request methods, request paths, request parameters, response parameters, etc.
- Configure Swagger in the configuration class, including the package paths to scan, API documentation information, global parameters, security schemes, security contexts, etc.
- Describe data models, enums, response parameters, and other information to help developers understand the functionality and parameters of the API.
- Use the @ApiIgnore annotation to exclude sensitive parameters from being displayed.
  

Finally, it's important to note that Swagger is just a specification and toolset. It cannot replace other testing methods such as unit testing and integration testing. During the development process, it's necessary to use a combination of testing approaches to ensure the quality and stability of the software.
