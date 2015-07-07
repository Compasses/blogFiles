title: "高性能MySQL 读书摘要 "
date: 2015-05-19 10:07:53
tags: "MYSQL"
---
##前言
因工作需要，要不断的使用MySQL，前段时间还参与了MySQL的性能测试，及profiling。发现MySQL还是非常有意思的，自己也非常感兴趣，于是买了本牛逼的书：《高性能MySQL 第三版》。书是很好，但是第一遍基本没什么感觉，基本上是粗略了解，很多细节还是掌握不好。现在重新学习希望能够有更好的提高。
读书摘要，既然是读书摘要就不会照搬原书，我会侧重点的做笔记，有意思的地方会多写，自己觉得不是很重要的东西会少写或者不写。但是内容的范围不会超出这本书。OK, Let's Start。
###MySQL逻辑结构
逻辑架构图如下：
![Mysql](/img/MySqlCapture.PNG)
分为三层结构，需要重点研究的是存储引擎层和查询优化层。存储引擎也主要研究InnoDB。
##并发控制
1. 读写锁： 在并发读写数据库表时使用，也叫共享锁和排他锁，读锁是共享的，是互不阻塞的，写锁是排他的，一个写锁会阻塞其他的读锁和写锁。
2. 锁粒度： 锁的数据越少，并发程度就越高，但锁的数量就会大增，锁的开销也会增加。这就需要一种平衡，即锁策略的选择。
3. 锁策略，包含**表锁**和**行级锁**。
4. 死锁： 多个事务以不同的顺序锁定资源时，就会可能产生死锁。InnoDB能检测到死锁的循环依赖（**how?**），对死锁的处理方法是回滚最少行级排它锁的事务。
5. MVCC： 多版本并发控制，是行级锁的变种，在很多情况下避免的加锁操作。工作在REPEATABLE READ 和 REPEATABLE COMMITTED两个隔离级别下。
6. 事务日志： 提高事务效率的一种方法，也叫预写式日志。日志操作是磁盘上小块区域内的顺序I/O，不是随机I/O，会快很多。关于顺序和随机I/O，需要后面讨论下。

如何检测死锁，在复杂系统里面是要重点考虑的，目前没有研究InnoDB的源码，不知道他是怎么判定死锁产生的。但是基于一般理论大致可以想一下它是怎么产生的，即多个线程加锁的顺序不一致，产生了循环依赖，基于此，可以设计一种数据结构，每个线程在试图加锁的时候就将该线程作为该锁的所有者，如果出现加锁失败，就要进行一次检测。每个锁的所有者里面是否有环，有环就说明有循环依赖，即可判定死锁，然后进行死锁解除。解除的策略估计会比较暴力，通过销毁某个死锁线程或者强制锁释放等等。[这篇文章](http://web.mit.edu/6.033/1997/reports/r03-ben.html)也有类似的讨论。

InnoDB中的MVCC实现机制： 在每行记录保存两个隐藏的列，一个是行的创建时间，一个是行的过期时间或者是删除时间。时间使用系统版本号标示，每个事务都会有一个，且递增。在REAPTABLE READ隔离级别下MVCC操作如下：
+ SELECT 满足两个条件： InnoDB只查找版本号早于当前事务版本的数据行。行的删除版本要么没有定义要么大于当前事务的版本号。
+ INSERT InnoDB为没一行保存当前系统版本号作为行版本号。
+ DELETE InnoDB为删除的每一行保存当前的版本号为删除版本号。
+ UPDATE InnoDB为新插入的行，保存当前的版本号为行版本号，同时保存当前系统版本号到原来的行作为删除的行作为行删除标示。与单纯的悲观锁和乐观锁，MVCC读操作简单，性能好，能保证只会读到符合标准的行。

MVCC工作在REAPTABLE READ 和 READ COMMIT两个隔离级别下。REAPTABLE READ 为可重复读，即同一个事务中多次读取同样的记录的结果是一致的。显然MVCC满足这点。READ COMMIT 提交读，一个事务开始时，只能更新到所有已提交事务的更改。即事务开始到提交前，所做的修改对其他事务都是不可见的。MVCC也天生支持。

##MySQL基准测试
本章主要是说的针对MySQL的基准测试，这里重点看下**sql-bench**和**sysbench**。 其中**sql-bench**只有在源码安装的时候才会有，二进制安装没有,**sysbench**需要单独安装。

**sql-bench** 是由perl脚本组成的测试工具。**sysbench**也可以不只是用来进行数据库的基准测试，比如CPU、I/O等。这些工具的使用咱不赘述，后续如有使用再更新到这里。

##服务器性能剖析
服务器性能剖析包含两个方面，一是应用程序，而是数据库；对应用程序剖析需要有相应的统计方法。例如PHP则需要统计每个方法的执行时间，执行数据库查询的时间，都可以在应用层获取；数据库上的性能剖析，就是分析并发查询时的性能问题。
针对PHP方面，目前正在开发性能剖析的脚本，保证能在生产环境上work。做完后会更新到这里。
数据库方面目前就使用了MySql的慢查询日志。慢查询日志的产生需要简单的配置：
```
1.  find /etc -name my.cnf; it should be locate in: sudo vi /etc/mysql/my.cnf;
2.  add lines: under [mysqld]
slow-query-log = 1
slow-query-log-file = /var/log/mysql/localhost-slow.log
long_query_time = 1
log-queries-not-using-indexes
if the directory /var/log/mysql/ does not exist, you need use : mkdir –p /var/log/mysql/ to create it.
3.  restart your daemon: sudo service mysql restart .
I have tested these steps on my Ubuntu machine.
```

令**long_query_time = 0**可以获得所有的查询语句，上述配置对MariaDB也是适用的。

获得的结果类似如下：
```
35 # User@Host: debian-sys-maint[debian-sys-maint] @ localhost []
 36 # Query_time: 0.000169  Lock_time: 0.000075 Rows_sent: 0  Rows_examined: 1
 37 SET timestamp=1430214485;
 38 select count(*) into @discard from `information_schema`.`PROCESSLIST`;
 39 # User@Host: debian-sys-maint[debian-sys-maint] @ localhost []
 40 # Query_time: 0.000359  Lock_time: 0.000111 Rows_sent: 0  Rows_examined: 2
 41 SET timestamp=1430214485;
 42 select count(*) into @discard from `information_schema`.`ROUTINES`;
 43 # User@Host: debian-sys-maint[debian-sys-maint] @ localhost []
 44 # Query_time: 0.001736  Lock_time: 0.000090 Rows_sent: 0  Rows_examined: 0
 45 SET timestamp=1430214485;
 46 select count(*) into @discard from `information_schema`.`TRIGGERS`;
 47 # User@Host: debian-sys-maint[debian-sys-maint] @ localhost []
 48 # Query_time: 0.001403  Lock_time: 0.000080 Rows_sent: 0  Rows_examined: 4
 49 SET timestamp=1430214485;
 50 select count(*) into @discard from `information_schema`.`VIEWS`;
 51 # Time: 150428 17:49:08
 52 # User@Host: root[root] @ localhost []
 53 # Query_time: 0.144277  Lock_time: 0.000052 Rows_sent: 10061  Rows_examined: 10061
 54 use occ_eshop;
 55 SET timestamp=1430214548;
 56 select * from wp_posts;
```
然后可以针对每一个查询进行分析，并剖析其性能问题。
<!--more-->
##Schema与数据类型优化
待续
##创建高性能的索引
待续
##查询性能优化
一个复杂查询还是多个简单查询：
切分查询：将大查询切分成小查询。每个查询功能完全一样。
分解关联查询：分解关联查询的方式重构查询有如下的优势：1，让缓存效率更高。2，查询分解后，执行单个查询可以减少锁的竞争。3.在应用层做关联，可以更容易对数据库进行拆分。更容易做到高性能和可扩展。4，减少冗余记录的查询。5.这样做相当于在应用中实现了哈希关联，而不是使用MYSQL的嵌套循环关联。某些场景哈希关联的效率高很多。
mysql客户端和服务器之间的通信协议是半双工的。show full processlist; 显示当前链接线程的状态。
将一个SQL转成一个执行计划，包含多个子阶段：解析SQL、预处理、优化SQL执行计划。
mysql通过关键字将SQL语句进行解析；生成一颗对应的解析树。预处理器根据一些mysql规则进一步检查解析树是否合法。
查询优化器：一条查询有很多种执行方式，并能都返回相同的结果。有很多原因导致MYSQL优化器选择错误的执行计划。1.统计信息不准确；2.执行计划中的成本估算不等同于实际的执行成本。。。。。优化策略可以简单的分为两种，一种是静态优化，一种动态优化。
MYSQL的优化类型：1.重新定义关联表的顺序。2.将外连接转化成内连接。3.使用等价变换规则，移除一些恒等成立和恒不成立的判断。4.优化COUNT MIN和MAX，得益于B-Tree结构。5.预估并转化为常数表达式6.覆盖索引扫描。7.子查询优化。8.提前终止查询。9.等值传播10.列表IN()的比较。使用IN的时候索引就用不了了。
MYSQL的概念中，每个查询都是一次关联。所以读取结果临时表也是一次关联。MYSQL执行关联的策略：MYSQL对任何关联都执行嵌套循环关联操作。即先在一个表中循环取出单条数据，然后再嵌套循环到下一个表中寻找匹配的行，依次下去，直到找到所有表中匹配的行。如果最后一个关联表无法找到更多的行后，MYSQL返回上一层关联表，看是否能够找到更多的匹配记录。
分别看一个内联和外联的例子：
```
select tb1.col1, tbl2.col2 from tb1 inner join tbl2 using(col3) where tb1.col1 in (5,6);
```
伪代码：
```
outer_iter = iterator over tb1 where col1 in (5, 6)
outer_row = outer_iter.next
while outer_row
     inner_iter = iterator over tbl2 where col3 = outer_row.col3
     inner_row = inner_iter.next
     while inner_row
          output [outer_row.col1 inner_row.col2]
          inner_row = inner_iter.next
     end
     outer_row = outer_iter.next
end
```

```
select tb1.col1, tbl2.col2 from tb1 left outer join tbl2 using(col3) where tb1.col1 in (5,6);
```
伪代码：
```
outer_iter = iterator over tb1 where col1 in (5, 6)
outer_row = outer_iter.next
while outer_row
     inner_iter = iterator over tbl2 where col3 = outer_row.col3
     inner_row = inner_iter.next
     if inner_row
          while inner_row
               output [outer_row.col1 inner_row.col2]
               inner_row = inner_iter.next
          end
     else 
          out [outer_row.col1, null]
     end
     outer_row = outer_iter.next
end
```
如果超过n个表的关联，那么需要检查n的阶乘中关联顺序；当需要关联的表超过optimizer_search_depth时，优化器就会使用贪婪搜索模式。show variables like 'optimizer_%';
排序优化：应尽可能避免排序或者尽可能避免对大量数据进行排序。
查询执行引擎，mysql根据查询计划完成整个查询。在执行过程中，有大量的操作需要通过调用存储引擎实现的接口来完成，这些接口为 handler API，查询中的每一个表由一个handler实例表示。

MySQL 查询优化的局限性
1. 关联子查询：where条件里面包含IN()的子查询。通常建议使用EXISTS()等效的改写查询获取更好的效率。对任何查询应该通过测试来验证猜想。

2. UNION的限制，mysql无法将限制条件从外层下推到内层，使得原本能够限制部分返回结果的条件无法应用到内层查询的优化上。因此UNION的两个子查询分别加上一个LIMIT 来减少临时表中的数据。

待续


##参考文献
1. 《高性能MySQL 第三版》