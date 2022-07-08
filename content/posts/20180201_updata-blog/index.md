---
title: "Update the BLOG steps" # Title of the blog post.
date: 2018-02-01T05:06:59-07:00 # Date of post creation.
description: "The steps of updating hugo blog." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: true # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Guide
tags:
  - Git
# comment: true # Disable comment if false.
---

Update blog steps. Update static pages and push them to Github Pages. 
<!--more-->
## UPDATE BLOG

### 1.create new blog
```
hugo new post/*.md
```
### 2.update the static website
```
hugo --theme=hugo-clarity --baseUrl="https://Jerrysmd.github.io/"
```
### 3.commi gitbubpages
```
cd public/
git add .
git commit -m 'update blog'
git push -u origin master
```
## COMPLETE OPERATION
```
hugo --theme=hugo-clarity --baseUrl="https://Jerrysmd.github.io/"
cd public/
git add .
git commit -m 'update blog'
git push -u origin master
```

## UPDATE HUGO THEME
```
cd theme/
mv hugo-clarity hugo-clarity.bak
git clone https://github.com/chipzoller/hugo-clarity
cp -rf hugo-clarity.bak/static/icons/ hugo-clarity/static/
```
