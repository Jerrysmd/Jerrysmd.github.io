---
title: "The size of structure in C" # Title of the blog post.
date: 2019-08-25T14:38:34+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code2.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - C
# comment: false # Disable comment if false.
---
The sizeof for a struct is not always equal to the sum of sizeof of each individual member. This is because of the padding added by the compiler to avoid alignment issues. Padding is only added when a structure member is followed by a member with a larger size or at the end of the structure.
<!--more-->
Different compilers might have different alignment constraints as C standards state that alignment of structure totally depends on the implementation.

* Case 1:

```c
struct A {    
	// sizeof(int) = 4 
    int x; 
    // Padding of 4 bytes 

    // sizeof(double) = 8 
    double z; 
    
    // sizeof(short int) = 2 
    short int y; 
    // Padding of 6 bytes 
}; 
```

Output:

​	Size of struct: 24

![Output1](/posts/picture/struct_sizeof_ex1.png "struct_sizeof_ex1")

The red portion represents the padding added for data alignment and the green portion represents the struct members. In this case, x (int) is followed by z (double), which is larger in size as compared to x. Hence padding is added after x. Also, padding is needed at the end for data alignment.

* Case 2:

```c
struct B { 
    // sizeof(double) = 8 
    double z; 
    
    // sizeof(int) = 4 
    int x; 
    
    // sizeof(short int) = 2 
    short int y; 
    // Padding of 2 bytes 
}; 
```

Output:

​	Size of struct: 16

![output2](/posts/picture/struct_sizeof_ex2.png "struct_sizeof_ex2")

In this case, the members of the structure are sorted in decreasing order of their sizes. Hence padding is required only at the end.


* Case 3:

```c
struct C { 
    // sizeof(double) = 8 
    double z; 
    
    // sizeof(short int) = 2 
    short int y; 
    // Padding of 2 bytes 
    
    // sizeof(int) = 4 
    int x; 
}; 
```

Output:

​	Size of struct: 16

![output3](/posts/picture/struct_sizeof_ex3.png "struct_sizeof_ex3")

In this case, y (short int) is followed by x (int) and hence padding is required after y. No padding is needed at the end in this case for data alignment.

C language doesn’t allow the compilers to reorder the struct members to reduce the amount of padding. In order to minimize the amount of padding, the struct members must be sorted in a descending order (similar to the case 2).
