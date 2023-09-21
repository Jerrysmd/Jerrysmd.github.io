---
title: "An Introduction to Blender 3D Modeling"
# subtitle: ""
date: 2023-08-23T21:54:46+08:00
# lastmod: 2023-08-23T21:54:46+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Modeling", "3D", "Blender"]
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

Blender is the free and open source 3D creation suite. It supports the entirety of the 3D pipeline—modeling, rigging, animation, simulation, rendering, compositing and motion tracking, even video editing and game creation.

<!--more-->

> Please take a look at my Blender project called "ImmersiveOffice" hosted on GitHub. You can find the project at the following URL: 
>
> [GitHub - archichen/ImmersiveOffice](https://github.com/archichen/ImmersiveOffice)

## Interface and Tool Operations

### Common Techniques

+ View Editing
  + Move view: `Shit` + `middle mouse button`
  + Rotate view: `Middle mouse button`
  + Zoom view: Scroll the `Middle mouse button`
+ View Adjusting
  + Front view:  `Numpad 1`
  + Side view: `Numpad 3`
  + Perspective view: `Numpad 5`
  + Top view: `Numpad 7`
  + Maximize display: `Numpad Solid dot` or **` + 3**
  + Independent display: `Slash`
+ Object Viewing
  + Front view:  **` + 1**
  + Side view: **` + 3**
  + Perspective view: **` + 5**
  + Top view: **` + 7**
+ Object Editing
  + Move: `G`
  + Rotate: `R`
  + Zoom: `S`
  + Based on this, click `XYZ` again to edit along the corresponding axis.

## Object Practice - Chair

+ Create Object: `Shit + A`

![image-20230827172853109](image-20230827172853109.png " ")

+ Switch to front view by pressing `Numpad 1`.
+ Enter editing mode: `Ctrl+ Tab` -> `6`

![image-20230827173829270](image-20230827173829270.png " ")

+ Transparent Display：`Alt + z` OR `activate it by clicking on the top-right corner`

+ Choose point mode and select the upper half

+ Compress this cube into a cushion: `G (Move object) + Z(Follow the Z-axis)`

+ Round the edges of the cuboid:

  1. `Ctrl+ Tab -> 6 (Enter editing mode)`

  2. `Activate Edge mode by clicking on the top-left corner`

  3. `Hold down the Shift key and left-click to select all the edges` OR `Press Alt + Shift and click on a face to perform a loop selection of edges`

  4. Rounding Operation: `Ctrl + B`+`click object`

  5. Set the Rounding attribute on the bottom-left corner

     ![image-20230904071429348](image-20230904071429348.png " ")

  6. Smooth shading: `Right-click on the object to apply Smooth shading`

+ Delete Object: `X`

+ Copy Object: `Shift + D`

+ Mirror copy：

  ![image-20230904073304757](image-20230904073304757.png " ")

+ Rotate: `R`

  ![image-20230904073813228](image-20230904073813228.png " ")

+ Scale down at the same proportion: `S`

## Material and Light Practice

+ Split Window: Place the mouse cursor on the top-left corner of the window border, and a crosshair cursor will appear. Dragging it will separate the view into separate windows.







To be continued...
