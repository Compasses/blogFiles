+++
author = "Jet He"
date = "2015-07-18T18:45:07+08:00"
description = "PHP 的几个框架分析对比"
keywords = ["PHP"]
tags = ["PHP"]
title = "PHP 框架之CodeIgniter & Laravel"
topics = ["PHP"]
type = "post"

+++

# 说明
最近产品考虑更换前端框架，重点考察了CodeIgniter 和 Laravel两个框架，现对其进行下对比分析。

# 总体对比

| | CodeIgniter |Laravel |
|---|:---|:---:|
|   Document| Good enough | Good enough |
|      Performance | 差不多 3倍于 Laravel    | |
|      MVC | Good enough | Good enough |
|      TWIG | 自己添加 TWIG lib    | 使用三方插件 |
|      third-party | 自己添加，放到指定目录 | composer managment |
|      Route | default mapping ："example.com/class/function/id/" can be remap, more code than Laravel | Simple and clear |
|      summary| 简单 精巧| 易用，更为丰满 |


CodeIgniter 基本上是个MVC的空架子，代码量极小，开发的花基本上 100%的掌控在自己手里。 Laravel还是加载了不少的三方 component，比CodeIgniter 庞大些。
对MVC的支持都很清晰，URL的路由也很简单易扩展。

# 测试环境：
主要是使用了Laravel 的HomeStead环境，通过virtual box + vagrant标准用法，加载Laravel的框架代码；要使其加载CodeIgniter框架，需要修改Nginx的配置，增加新的server，只要端口号换成新的，root指定到CodeIgniter的跟目录即可。
总体上是Nginx+php5-fpm+mysql+ Ubuntu + CodeIgniter 源码包 + Laravel 源码包。源码包共享在本机上。

# 测试页面：
Modal：使用product数据，获取某个product上的所有信息。
View：引入Twig模板引擎，创建几个twig模板，在controller层render。
Controller：调用modal获取数据，使用 twig render 页面。

这两个框架都用非常清晰的 MVC结构，上述页面的代码几乎可以在两者之间无缝迁移。

# 性能对比测试：

针对这个页面进行性能测试：页面大小为 8KB， 加载一个已有的CSS文件大小为 87.7KB。
使用Apache的ab test进行测试：
AB test:
ab -n 1000 -c 80 http://192.168.10.10:8080/productdetail/
## Laravel 结果:
Server Software:        nginx/1.8.0
Server Hostname:        192.168.10.10
Server Port:            80

Document Path:          /product/
Document Length:        200205 bytes

Concurrency Level:      80
Time taken for tests:   112.455 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      200793036 bytes
HTML transferred:       200205000 bytes
Requests per second:    8.89 [#/sec] (mean)
Time per request:       8996.416 [ms] (mean)
Time per request:       112.455 [ms] (mean, across all concurrent requests)
Transfer rate:          1743.69 [Kbytes/sec] received

Connection Times (ms)

min  mean[+/-sd] median   max
Connect:        0    1   1.0      0      18
Processing:  2001 8604 1574.3   8488   17271
Waiting:     1999 8594 1572.4   8480   17269
Total:       2005 8604 1574.0   8490   17271
WARNING: The median and mean for the initial connection time are not within a normal deviation

These results are probably not that reliable.

Percentage of the requests served within a certain time (ms)

  50%   8490

  66%   8695

  75%   8960

  80%   9098

  90%   9951

  95%  12074

  98%  12548

  99%  12944

 100%  17271 (longest request)

## CodeIgniter 结果:

Server Software:        nginx/1.8.0
Server Hostname:        192.168.10.10
Server Port:            8080

Document Path:          /productdetail/
Document Length:        200205 bytes

Concurrency Level:      80
Time taken for tests:   40.332 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      200341000 bytes
HTML transferred:       200205000 bytes
Requests per second:    24.79 [#/sec] (mean)
Time per request:       3226.569 [ms] (mean)
Time per request:       40.332 [ms] (mean, across all concurrent requests)
Transfer rate:          4850.86 [Kbytes/sec] received

Connection Times (ms)

min  mean[+/-sd] median   max
Connect:        0    1   1.3      0      23
Processing:   346 3097 456.3   3169    3649
Waiting:      343 3089 455.7   3161    3645
Total:        351 3098 455.5   3170    3649

Percentage of the requests served within a certain time (ms)

  50%   3170

  66%   3216

  75%   3250

  80%   3270

  90%   3326

  95%   3467

  98%   3551

  99%   3582

 100%   3649 (longest request)

# 总结
CodeIgniter 更轻便，代码可以做到100%掌控；Laravel相比CodeIgniter更加丰满些，使用composer管理扩展性增强了不少。
如果选择从头开始的话，感觉CodeIgniter更好些。

