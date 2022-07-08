---
title: "SQLcipher Guide" # Title of the blog post.
date: 2018-11-18T21:58:51-08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/data1.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - SQL
  - C
# comment: false # Disable comment if false.
---
SQLCipher is based on SQLite, and thus, the majority of the accessible API is identical to the C/C++ interface for SQLite 3. However, SQLCipher does add a number of security specific extensions in the form of PRAGMAs, SQL Functions and C Functions.
<!--more-->

## 1. Build SQLcipher from source

1. $ git clone https://github.com/sqlcipher/sqlcipher.git
2. $ cd sqlcipher
3. $ ./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2" LDFLAGS="-lcrypto"
4. $ make
5. $ make install *#if you want to do a system wide install of SQLCipher*

Mark the output of make install, especially the following lines:

* libtool: install: /usr/bin/install -c .libs/libsqlcipher.a /usr/local/lib/libsqlcipher.a
* /usr/bin/install -c -m 0644 sqlite3.h /usr/local/include/sqlcipher

these are the folders of SQLcipher headers and the library necessary when building proper C project.

## 2. Building minimal C project example

In SQLite_example.c put the following lines:

```c
#include "sqlite3.h" //We want to SQLCipher extension, rather then a system wide SQLite header
rc = sqlite3_open("test.db",&db); //open SQLite database test.db
rc = sqlite3_key(db,"1q2w3e4r",8); //apply encryption to previously opened database
```

Build you example:

```shell
$gcc SQLite_example.c -o SQLtest -I /path/to/local/folder/with/sqlcipher/header/files/ -L /path/to/local/folder/with/sqlcipher/library.a -l sqlcipher
```

e.g. with paths extracted from the output of $make install

```shell
$gcc SQLite_example.c -o SQLtest -I /usr/local/include/sqlcipher -L /usr/local/lib/libsqlcipher.a -lsqlcipher
```

Finally, make sure that your SQLCipher library is in the system wide library path e.g. for (Arch)Linux:

```shell
$ export LD_LIBRARY_PATH=/usr/local/lib/
```

Run your test code ((Arch)Linux):

```shell
$ ./SQLtest
```



