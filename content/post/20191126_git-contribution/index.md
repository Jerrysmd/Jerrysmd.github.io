---
title: "Git Contribution" # Title of the blog post.
date: 2019-11-26T11:22:47+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/github.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - git
# comment: false # Disable comment if false.
---
Contribution graph shows activity from public repositories. You can choose to show activity from both public and private repositories, with specific details of your activity in private repositories anonymized.
<!--more-->

## Update local git config

```shell
git config --global user.name “github’s Name”
 
git config --global user.email "github@*.com"
```



## Update commit history

If you do not want to waste your commit history.

we can use 'git log' to see the git record

```shell
git log
```

we need to edit all of the history of commit and push.

```shell
git filter-branch -f --env-filter '
if [ "$GIT_AUTHOR_NAME" = "oldName" ]
then
export GIT_AUTHOR_NAME="newName"
export GIT_AUTHOR_EMAIL="newEmail"
fi
' HEAD
 
git filter-branch -f --env-filter '
if [ "$GIT_COMMITTER_NAME" = "oldName" ]
then
export GIT_COMMITTER_NAME="newName"
export GIT_COMMITTER_EMAIL="newEmail"
fi
' HEAD
```

如果无差别把所有都改的话去掉if..fi

```shell
git filter-branch -f --env-filter "
GIT_AUTHOR_NAME='newName';
GIT_AUTHOR_EMAIL='newEmail';
GIT_COMMITTER_NAME='newName';
GIT_COMMITTER_EMAIL='newEmail'
" HEAD
```

## Update Git push

你这里将你本地git的账户和邮箱重新设置了,但是github并没有那么智能就能判断你是原来你系统默认的用户.

也就是说你新配置的用户和你默认的被github识别成两个用户.

这样你以后操作的时候commit 或者 push的时候有可能产生冲突.

Solution:

1. 使用强制push的方法:

```shell
git push -u origin master -f
```

这样会使远程修改丢失，一般是不可取的，尤其是多人协作开发的时候。

2. push前先将远程repository修改pull下来

```shell
git pull origin master
git push -u origin master
```

3. 若不想merge远程和本地修改，可以先创建新的分支：

```shell
git branch [name]
#然后push
git push -u origin [name]
```