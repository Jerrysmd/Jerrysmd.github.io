---
title: "Automated Deployment of SpringBoot with Jenkins and Docker"
# subtitle: ""
date: 2024-03-08T17:56:44+08:00
# lastmod: 2024-03-08T17:56:44+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Docker", "Jenkins", "DevOps", "CI/CD", "Java", "Spring", "Linux"]
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

Explore the power of Jenkins and Docker for automating the deployment of your SpringBoot projects. This blog post walks through integrating these tools to create a seamless CI/CD pipeline, enabling you to build, test, and deploy your applications as containerized services with ease, enhancing your DevOps skills.

<!--more-->

## Ship Code Whole Progress

![img](0x1664.webp " ")

1. The process starts with a product owner creating user stories based on requirements.
2. The dev team picks up the user stories from the backlog and puts them into a sprint for a two-week dev cycle.
3. The developers commit source code into the code repository Git.
4. A build is triggered in Jenkins. The source code must pass unit tests, code coverage threshold, and gates in SonarQube.
5. Once the build is successful, the build is stored in artifactory. Then the build is deployed into the dev environment.
6. There might be multiple dev teams working on different features. The features need to be tested independently, so they are deployed to QA1 and QA2.
7. The QA team picks up the new QA environments and performs QA testing, regression testing, and performance testing.
8. Once the QA builds pass the QA team’s verification, they are deployed to the UAT environment.
9. If the UAT testing is successful, the builds become release candidates and will be deployed to the production environment on schedule.
10. SRE (Site Reliability Engineering) team is responsible for prod monitoring.

## Automated deployment Process
