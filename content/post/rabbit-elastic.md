+++
author = "Jet He"
date = "2017-01-06T17:08:03+08:00"
description = "ElasticSearch使用"
draft = false
keywords = ["RabbitMQ", "ElasticSearch"]
tags = ["ElasticSearch"]
title = "RabbitMQ and ElasticSearch"
topics = ["ElasticSearch"]
type = "post"

+++

项目需要产品中引入了ElasticSearch，第一阶段的使用场景是直接消费RabbitMQ来persist相关的业务数据，改变以前通过message driven走API Call 的方式persist数据。调整过后性能提升了一个数量级。第二阶段将会使用ElasticSearch作为产品的全文检索引擎使用，类似于Search加速组件。
在这个过程中开发了不少原型代码，也做了一系列的笔记，项目是[elastic-rabbitmq](https://github.com/compasses/elastic-rabbitmq)，相关的notes：

1. [ElasticSearch 深入理解 一：基础概念&源码启动](https://github.com/compasses/elastic-rabbitmq/blob/master/notes/basic&sourcestart.md)
2. [ElasticSearch 深入理解 二：乐观锁&版本冲突管理](https://github.com/compasses/elastic-rabbitmq/blob/master/notes/optimisticlock&versionconflicthandle.md)
3. [ElasticSearch 深入理解 三：集群部署设计](https://github.com/compasses/elastic-rabbitmq/blob/master/notes/cluster_relateddesign.md)


项目继续，也会持续更新。
