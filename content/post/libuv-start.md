+++
author = "Jet He"
date = "2015-06-03T19:45:07+08:00"
description = "libuv 学习"
keywords = ["C++"]
tags = ["C++"]
title = "libuv 初认识"
topics = ["C++"]
type = "post"

+++
说明： 本篇文章主要从[An Introduction to libuv](http://nikhilm.github.io/uvbook/)这本书翻译学习而来。
## 开始
libuv是NodeJS的底层库，实现了异步、事件驱动的编程模式。主要功能就是实现了事件循环，基于I/O或者其他事件的通知回调。比如广泛使用回调的定时器、非阻塞的网络通信、异步的文件读取、子线程相关的通信等等。

### 事件循环
libuv的编译就不用多说，参考libuv的[github网址]( https://github.com/libuv/libuv)。就能轻松搞定。我是在Linux上做的相关实验，版本是： Linux ubuntu 3.16.0-33-generic #44~14.04.1-Ubuntu SMP Fri Mar 13 10:33:29 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux。

先从运行一个程序开始：
```
#include "uv.h"
#include <stdio.h>
#include <stdlib.h>

int main() {
    uv_loop_t *loop = malloc(sizeof(uv_loop_t));
    uv_loop_init(loop);
    printf("Now quitting.\n");
    uv_run(loop, UV_RUN_DEFAULT);
    uv_loop_close(loop);
    free(loop);
    return 0;
}
```
编译要使用gyp，因为源码包里面带有相应的samples，根据samples很容易的写出一个gyp 的build文件：
```
{
  'targets': [
    {
      'dependencies': ['../../uv.gyp:libuv'],
      'target_name': 'helloword',
      'type': 'executable',
      'sources': [
        'main.c',
      ]
    }
  ],
}
```
然后执行** gyp --format=make -Duv_library=static_library --depth=$PWD build.gyp **生产相应的makefile，最后直接执行**make**，就会生成自己想要的可执行文件。
gyp算上一个神器，比起自己写makefile轻松了很多，而且在跨平台方面也表现很好，后续有时间也好好学习下。
待续。





