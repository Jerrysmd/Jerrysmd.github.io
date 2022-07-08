---
title: "Tensorflow Identify Simple Captcha" # Title of the blog post.
date: 2021-02-04T07:10:16+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# thumbnail: "images/.png" # Sets thumbnail image appearing inside card on homepage.
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# featureImageAlt: 'Description of image' # Alternative text for featured image.
# featureImageCap: 'This is the featured image.' # Caption (optional).
codeLineNumbers: true # Override global value for showing of line numbers within code block.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - TensorFlow
  - machinelearning
comments: true # Disable comment if false.
---

CAPTCHA stands for 'Completely Automated Public Turing test to tell Computers and Humans Apart'. It’s already possible to solve it with the rise of deep learning and computer vision.

<!--more-->

## 大体流程

1. 抓取验证码
2. 给验证码打标签
3. 图片预处理
4. 保存数据集
5. 构建模型训练
6. 提取模型使用

## 抓取验证码

这个简单，随便什么方式，循环下载一大堆，这里不再赘述。我这里下载了 750 张验证码，用 500 张做训练，剩下 250 张验证模型效果。

## 给验证码打标签

这里的验证码有750张之巨，要是手工给每个验证码打标签，那一定累尿了。这时候就可以使用人工打码服务，用廉价劳动力帮我们做这件事。人工打码后把识别结果保存下来。这里的代码就不提供了，看你用哪家的验证码服务。

## 图片预处理

1. **图片信息：** 此验证码是 68x23，JPG格式
2. **二值化：** 我确信这个验证码足够简单，在丢失图片的颜色信息后仍然能被很好的识别。并且可以降低模型复杂度，因此我们可以将图片二值化。即只有两个颜色，全黑或者全白。
3. **切割验证码：** 观察验证码，没有特别扭曲或者粘连，所以我们可以把验证码平均切割成4块，分别识别，这样图片识别模型就只需要处理10个分类（如果有字母那将是36个分类而已）由于验证码外面有一圈边框，所以顺带把边框也去掉了。
4. **处理结果：** 16x21，黑白2位

相关 Python 代码如下：

```python
img = Image.open(file).convert('L') # 读取图片并灰度化

img = img.crop((2, 1, 66, 22)) # 裁掉边变成 64x21

# 分离数字
img1 = img.crop((0, 0, 16, 21))
img2 = img.crop((16, 0, 32, 21))
img3 = img.crop((32, 0, 48, 21))
img4 = img.crop((48, 0, 64, 21))

img1 = np.array(img1).flatten() # 扁平化，把二维弄成一维
img1 = list(map(lambda x: 1 if x <= 180 else 0, img1)) # 二值化
img2 = np.array(img2).flatten()
img2 = list(map(lambda x: 1 if x <= 180 else 0, img2))
img3 = np.array(img3).flatten()
img3 = list(map(lambda x: 1 if x <= 180 else 0, img3))
img4 = np.array(img4).flatten()
img4 = list(map(lambda x: 1 if x <= 180 else 0, img4))
```

## 保存数据集

数据集有输入输入数据和标签数据，训练数据和测试数据。 因为数据量不大，简便起见，直接把数据存成python文件，供模型调用。就不保存为其他文件，然后用 *pandas* 什么的来读取了。

最终我们的输入模型的数据形状为 **[[0,1,0,1,0,1,0,1...],[0,1,0,1,0,1,0,1...],...]** 标签数据很特殊，本质上我们是对输入的数据进行分类，所以虽然标签应该是0到9的数字，但是这里我们使标签数据格式是 *one-hot vectors* **[[1,0,0,0,0,0,0,0,0,0,0],...]** 一个one-hot向量除了某一位的数字是1以外其余各维度数字都是0**，比如[1,0,0,0,0,0,0,0,0,0] 代表1，[0,1,0,0,0,0,0,0,0,0]代表2. 更进一步，这里的 one-hot 向量其实代表着对应的数据分成这十类的概率。概率为1就是正确的分类。

相关 Python 代码如下：

```python
# 保存输入数据
def px(prefix, img1, img2, img3, img4):
    with open('./data/' + prefix + '_images.py', 'a+') as f:
        print(img1, file=f, end=",\n")
        print(img2, file=f, end=",\n")
        print(img3, file=f, end=",\n")
        print(img4, file=f, end=",\n")

# 保存标签数据
def py(prefix, code):
    with open('./data/' + prefix + '_labels.py', 'a+') as f:
        for x in range(4):
            tmp = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            tmp[int(code[x])] = 1
            print(tmp, file=f, end=",\n")
```

经过上面两步，我们在就获得了训练和测试用的数据和标签数据

## 构建模型训练

数据准备好啦，到了要搭建“管道”的时候了。 也就是你需要告诉 TensorFlow：

### 1. 输入数据的形状是怎样的？

```python
x = tf.placeholder(tf.float32, [None, DLEN])
```

None 表示不定义我们有多少训练数据，DLEN是 16*21，即一维化的图片的大小。

### 2. 输出数据的形状是怎样的？

```python
y_ = tf.placeholder("float", [None, 10])
```

同样None 表示不定义我们有多少训练数据，10 就是标签数据的维度，即图片有 10 个分类。每个分类对应着一个概率，所以是浮点类型。

### 3. 输入数据，模型，标签数据怎样拟合？

```python
W = tf.Variable(tf.zeros([DLEN, 10])) # 权重
b = tf.Variable(tf.zeros([10])) # 偏置

y = tf.nn.softmax(tf.matmul(x, W) + b)
```

是不是一个很简单的模型？大体就是 **y = softmax(Wx+b)** 其中 W 和 b 是 TensorFlow 中的变量，他们保存着模型在训练过程中的数据，需要定义出来。而我们模型训练的目的，也就是把 W 和 b 的值确定，使得这个式子可以更好的拟合数据。 *softmax* 是所谓的激活函数，把线性的结果转换成我们需要的样式，也就是分类概率的分布。 关于 *softmax* 之类更多解释请查看参考链接。

### 4. 怎样评估模型的好坏？

模型训练就是为了使模型输出结果和实际情况相差尽可能小。所以要定义评估方式。 这里用所谓的*交叉熵*来评估。

```python
cross_entropy = -tf.reduce_sum(y_*tf.log(y))
```

### 5. 怎样最小化误差？

现在 TensorFlow 已经知道了足够的信息，它要做的工作就是让模型的误差足够小，它会使出各种方法使上面定义的交叉熵 *cross_entropy* 变得尽可能小。 TensorFlow 内置了不少方式可以达到这个目的，不同方式有不同的特点和适用条件。在这里使用梯度下降法来实现这个目的。

```python
train_step = tf.train.GradientDescentOptimizer(0.01).minimize(cross_entropy)
```

### 训练准备

大家知道 Python 作为解释型语言，运行效率不能算是太好，而这种机器学习基本是需要大量计算力的场合。TensorFlow 在底层是用 C++ 写就，在 Python 端只是一个操作端口，所有的计算都要交给底层处理。这自然就引出了**会话**的概念，底层和调用层需要通信。也正是这个特点，TensorFlow 支持很多其他语言接入，如 Java, C，而不仅仅是 Python。 和底层通信是通过会话完成的。我们可以通过一行代码来启动会话：

```python
sess = tf.Session()
# 代码...
sess.close()
```

别忘了在使用完后关闭会话。当然你也可以使用 Python 的 *with* 语句来自动管理。

在 TensorFlow 中，变量都是需要在会话启动之后初始化才能使用。

```python
sess.run(tf.global_variables_initializer())
```

### 开始训练

```python
for i in range(DNUM):
    batch_xs = [train_images.data[i]]
    batch_ys = [train_labels.data[i]]
    sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})
```

我们把模型和训练数据交给会话，底层就自动帮我们处理啦。 我们可以一次传入任意数量数据给模型（上面设置None的作用），为了训练效果，可以适当调节每一批次训练的数据。甚至于有时候还要随机选择数据以获得更好的训练效果。在这里我们就一条一条训练了，反正最后效果还可以。要了解更多可以查看参考链接。

### 检验训练结果

这里我们的测试数据就要派上用场了

```python
correct_prediction = tf.equal(tf.argmax(y,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
print(sess.run(accuracy, feed_dict={x: test_images.data, y_: test_labels.data}))
```

我们模型输出是一个数组，里面存着每个分类的概率，所以我们要拿出概率最大的分类和测试标签比较。看在这 250 条测试数据里面，正确率是多少。当然这些也是定义完操作步骤，交给会话来运行处理的。

## 提取模型使用

在上面我们已经把模型训练好了，而且效果还不错哦，近 99% 的正确率，或许比人工打码还高一些呢（获取测试数据时候常常返回有错误的值）。但是问题来了，我现在要把这个模型用于生产怎么办，总不可能每次都训练一次吧。在这里，我们就要使用到 TensorFlow 的模型保存和载入功能了。

### 保存模型

先在模型训练的时候保存模型，定义一个 saver，然后直接把会话保存到一个目录就好了。

```python
saver = tf.train.Saver()
# 训练代码
# ...
saver.save(sess, 'model/model')
sess.close()
```

当然这里的 saver 也有不少配置，比如保存最近多少批次的训练结果之类，可以自行查资料。

## 恢复模型

同样恢复模型也很简单

```python
saver.restore(sess, "model/model")
```

当然你还是需要定义好模型，才能恢复。我的理解是这里模型保存的是训练过程中各个变量的值，权重偏置什么的，所以结构架子还是要事先搭好才行。
