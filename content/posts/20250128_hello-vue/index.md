---
title: "Hello World Vue 3"
# subtitle: ""
date: 2025-01-28T21:42:06+08:00
# lastmod: 2025-01-18T21:42:06+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Vue", "Frontend"]
categories: ["Technology"]

# featuredImage: ""
# featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
# ruby: true
# fraction: true
# fontawesome: true
# linkToMarkdown: true
# rssFullText: false

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
math:
  enable: false
#   # ...
# mapbox:
#   # ...
# share:
#   enable: true
#   # ...
comment:
  enable: true
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
Life is short, I learn Vue. Vue is a JavaScript framework for building user interfaces. It builds on top of standard HTML, CSS, and JavaScript and provides a declarative, component-based programming model that helps you efficiently develop user interfaces of any complexity.
<!--more-->

## Basic concepts

+ code language: TypeScript
+ API style: Composition API

> Vue 3 recommends Composition API over Options API for several key reasons:
> 1. **Better Logic Organization**  
   Composition API lets you group related logic together (state, computed props, methods) in a cohesive way, rather than splitting them across different options blocks (`data`, `methods`, `computed`).
> 2. **TypeScript Support**  
   Composition API works naturally with TypeScript, offering better type inference and code completion compared to Options API's `this`-based patterns.
> 3. **Code Reusability**  
   You can extract reactive logic into **composable functions** that work across components, solving the mixin limitations of Options API.

+ shorthand：script setup syntax

## Create vue3

Two method
+ vue-cli
+ vite

> vite:
>
> ```shell
> npm create vue@latest
> ```
>
> ```cmd
> ✔ Project name: … <your-project-name>
> ✔ Add TypeScript? … No / Yes
> ✔ Add JSX Support? … No / Yes
> ✔ Add Vue Router for Single Page Application development? … No / Yes
> ✔ Add Pinia for state management? … No / Yes
> ✔ Add Vitest for Unit testing? … No / Yes
> ✔ Add an End-to-End Testing Solution? … No / Cypress / Nightwatch / Playwright
> ✔ Add ESLint for code quality? … No / Yes
> ✔ Add Prettier for code formatting? … No / Yes
> ✔ Add Vue DevTools 7 extension for debugging? (experimental) … No / Yes
> 
> Scaffolding project in ./<your-project-name>...
> Done.
> ```

## Code structure
+ /
  + `./env.d.ts`: typeScript definition file
  
  + `./index.html`: entry html file
  
  + `./package.json`,`./package-lock.json`: package manager file
  
  + `./tsconfig.json`, `./tsconfig.node.json`, `./tsconfig.app.json`: TypeScript configuration file
  
  + `./vite.config.ts`: vite configuration file, install plugin, configure server, etc.
  
  + /src
  
    + `main.ts`: entry file
    
      ```ts
      import { createApp } from 'vue'
      // import the root component App from a single-file component.
      import App from './App.vue'
      
      createApp(App).mount('#app')
      ```
    
      most real applications are organized into a tree of nested, reusable components. For example, a Todo application's component tree might look like this:
    
      ```shell
      App (root component)
      ├─ TodoList
      │  └─ TodoItem
      │     ├─ TodoDeleteButton
      │     └─ TodoEditButton
      └─ TodoFooter
         ├─ TodoClearButton
         └─ TodoStatistics
      ```
    
    + `App.vue`: root component
  
      ```vue
      <template>
        <!-- html code -->
      </template>
      
      <script setup lang="ts">
      // script code
      </script>
      
      <style scoped>
      /* css code */
      </style>
      ```
      
    + /components
    
      + `Person.vue`
      
        ```vue
        <script setup lang="ts">
        // script code
        </script>
        
        <template>
          <!-- html code -->
        </template>
        
        <style scoped>
        /* css code */
        </style>
        ```

## Core conceptes

### Composition API vs Options API

Options API: the function is split into several options, such as `data`, `methods`, `computed`, `watch`. Every time you want to change the requirement, you need to modify `data`, `methods`, `computed` and `watch`.

Composition API: the function is merged into one function.

### Start with the setup function

```vue
<script setup lang="ts" name="Person1">
import { ref } from 'vue';
const name = ref('Jerry');
const age = ref(18);
const tel = ref('123456789');
const showTel = () => {
    alert(tel.value);
};
const changeName = () => {
    name.value = 'Tom';
};
const changeAge = () => {
    age.value += 1;
};
</script>

<template>
    <div class="person">
        <h2>name: {{ name }}</h2>
        <h2>age: {{ age }}</h2>
        <button @click="changeName">change name</button>
        <button @click="changeAge">change age</button>
        <button @click="showTel">show tel</button>
    </div>
</template>

<style scoped></style>
```



> let vs const
>
> + `const`: constant, the value is not allowed to be changed, suitable for 95% situation
> + `let`: the value is allowed to be changed
> + `var`: old way, not recommended

> function vs const + arrow function
>
> + `function`: the function will be promoted to the global scope, can be used before the declaration
> + `const + arrow function`: can't be used before the declaration. Vue3 recommends using arrow function. Keep the same style with the Composition API.


### ref: define basic reactive variables

+ Function: define a reactive variable
+ Syntax: `const name = ref('Jerry')`
+ Return: a `RefImpl` object, `ref.value` is reactive
+ Usage: 
  + using `ref.value` in the js code
  + using `{{ ref }}` in the template
  + ref is not reactive, but `ref.value` is reactive


### reactive: define a reactive object

+ Function: define a reactive object
+ Syntax: `const obj = reactive({ name: 'Jerry', age: 18 })`
+ Return: a `Proxy` object, the properties of the object are reactive
+ Usage: 
  + using `obj.name` in the js code
  + using `{{ obj.name }}` in the template

> ref vs reactive
> + basic type and object who has few levels use ref
> + object who has multiple levels use reactive





