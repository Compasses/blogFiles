+++
author = "Jet He"
date = "2015-05-19T10:45:07+08:00"
description = "straight_join 的使用场景分析"
keywords = ["MySQL"]
tags = ["MySQL"]
title = "straight_join when and why"
topics = ["MySQL"]
type = "post"

+++

### 问题过程
最近优化了一个查询语句，使用到了straight_join这个查询提示，现对其做下总结。
先看下这个查询语句：
```
SELECT wp_posts.ID
FROM wp_posts
INNER JOIN wp_postmeta ON (wp_posts.ID = wp_postmeta.post_id)
INNER JOIN
  (SELECT
   STRAIGHT_JOIN DISTINCT wp_posts.ID
   FROM wp_posts
   INNER JOIN wp_postmeta meta0 ON meta0.post_id = wp_posts.id
   AND meta0.meta_key = 'sysfield_code'
   AND CAST(meta0.meta_value AS CHAR) LIKE '%s%'
   INNER JOIN wp_postmeta meta1 ON meta1.post_id = wp_posts.id
   AND meta1.meta_key = 'price_sales_RMB'
   AND CAST(meta1.meta_value AS DECIMAL(10,4)) > '20'
   INNER JOIN wp_postmeta meta2 ON meta2.post_id = wp_posts.id
   AND meta2.meta_key = 'price_standard_RMB'
   AND CAST(meta2.meta_value AS DECIMAL(10,4)) > '20'
   INNER JOIN wp_postmeta meta3 ON meta3.post_id = wp_posts.id
   AND meta3.meta_key = 'price_sales_USD'
   AND CAST(meta3.meta_value AS DECIMAL(10,4)) > '10'
   INNER JOIN wp_postmeta meta4 ON meta4.post_id = wp_posts.id
   AND meta4.meta_key = 'price_standard_USD'
   AND CAST(meta4.meta_value AS DECIMAL(10,4)) > '5'
   INNER JOIN wp_postmeta meta5 ON meta5.post_id = wp_posts.id
   AND meta5.meta_key = 'sysfield_brand'
   AND CAST(meta5.meta_value AS CHAR) = 'Midori'
   INNER JOIN wp_postmeta meta6 ON meta6.post_id = wp_posts.id
   AND meta6.meta_key = 'sysfield_manufacturer'
   AND CAST(meta6.meta_value AS CHAR) = 'aaaaaaaaa'
   INNER JOIN wp_postmeta meta7 ON meta7.post_id = wp_posts.id
   AND meta7.meta_key = 'udf_100000001'
   AND CAST(meta7.meta_value AS CHAR) = '肉身'
   INNER JOIN wp_postmeta meta8 ON meta8.post_id = wp_posts.id
   AND meta8.meta_key = 'udf_100000004'
   AND CAST(meta8.meta_value AS CHAR) = '30'
   WHERE 1=1
     AND (wp_posts.post_type = 'product')
     AND (wp_posts.post_status = 'publish'
          OR wp_posts.post_status = 'private')
     AND wp_posts.post_title LIKE '%s%'
     AND (wp_posts.ID IN
            (SELECT object_id
             FROM wp_term_relationships
             WHERE term_taxonomy_id IN
                 (SELECT term_taxonomy_id
                  FROM wp_term_taxonomy
                  WHERE term_id IN (100000001))))
     AND wp_posts.post_date > '2015-06-04 10:40:00') collection ON collection.ID = wp_posts.ID
INNER JOIN
  (SELECT DISTINCT wp_posts.ID
   FROM wp_posts
   INNER JOIN wp_postmeta meta0 ON meta0.post_id = wp_posts.id
   AND (meta0.meta_key = 'price_standard_min_RMB'
        AND CAST(meta0.meta_value AS DECIMAL(10,4)) BETWEEN '0' AND '0')
   INNER JOIN wp_postmeta meta1 ON meta1.post_id = wp_posts.id
   AND (meta1.meta_key = 'sysfield_manufacturer'
        AND CAST(meta1.meta_value AS CHAR) = 'aaaaaaaaa')
   INNER JOIN wp_postmeta meta2 ON meta2.post_id = wp_posts.id
   AND (meta2.meta_key = 'sysfield_brand'
        AND CAST(meta2.meta_value AS CHAR) = 'Midori')
   INNER JOIN wp_postmeta meta3 ON meta3.post_id = wp_posts.id
   AND (meta3.meta_key = 'sysfield_stamp'
        AND CAST(meta3.meta_value AS CHAR) = 'sddd')
   INNER JOIN wp_postmeta meta4 ON meta4.post_id = wp_posts.id
   AND (meta4.meta_key = 'udf_100000001'
        AND CAST(meta4.meta_value AS CHAR) IN ('人肉',
                                               '肉身',
                                               '精神'))
   INNER JOIN wp_postmeta meta5 ON meta5.post_id = wp_posts.id
   AND (meta5.meta_key = 'udf_100000002'
        AND CAST(meta5.meta_value AS CHAR) IN ('20',
                                               '30',
                                               '40'))
   INNER JOIN wp_postmeta meta6 ON meta6.post_id = wp_posts.id
   AND (meta6.meta_key = 'udf_100000003'
        AND CAST(meta6.meta_value AS CHAR) IN ('10',
                                               '20',
                                               '30'))
   INNER JOIN wp_postmeta meta7 ON meta7.post_id = wp_posts.id
   AND (meta7.meta_key = 'udf_100000004'
        AND CAST(meta7.meta_value AS CHAR) IN ('30',
                                               '40',
                                               '50'))
   INNER JOIN wp_postmeta meta8 ON meta8.post_id = wp_posts.id
   AND (meta8.meta_key = 'variant_200000001'
        AND CAST(meta8.meta_value AS CHAR) IN ('200000001',
                                               '200000002',
                                               '200000003'))
   INNER JOIN wp_postmeta meta9 ON meta9.post_id = wp_posts.id
   AND (meta9.meta_key = 'variant_200000002'
        AND CAST(meta9.meta_value AS CHAR) = '200000006')
   WHERE 1=1
     AND (wp_posts.post_type = 'product')) filter ON filter.ID = wp_posts.ID
WHERE 1=1
  AND wp_posts.post_type = 'product'
  AND (wp_posts.post_status = 'publish'
       OR wp_posts.post_status = 'private')
GROUP BY wp_posts.ID
ORDER BY post_date DESC LIMIT 0,
                              12
```
是不是庞大无比，的确这样的查询语句对MySQL来说过去庞大了，因为这个SQL关联次数过多了。
过多的join导致MySQL的查询优化器变得很慢并且往往优化后的结果很不理想。对于MySQL来说N个表的关联就是N的阶层个优化顺序，即MySQL要检查N的阶层个不同的表的顺序，寻找最优化的查询顺序。
<!--more-->
通过设置profiling，然后通过** show profile for query xx**得到结果可以说明这一点：

| Status               | Duration |
|---|:---|
| starting             | 0.000441 |
| checking permissions | 0.000009 |
| checking permissions | 0.000004 |
| checking permissions | 0.000004 |
| checking permissions | 0.000010 |
| checking permissions | 0.000004 |
| checking permissions | 0.000004 |
| checking permissions | 0.000003 |
| checking permissions | 0.000003 |
| checking permissions | 0.000003 |
| checking permissions | 0.000004 |
| checking permissions | 0.000003 |
| checking permissions | 0.000004 |
| checking permissions | 0.000004 |
| checking permissions | 0.000003 |
| checking permissions | 0.000008 |
| Opening tables       | 0.000732 |
| init                 | 0.000073 |
| System lock          | 0.000030 |
| optimizing           | 0.000007 |
| optimizing           | 0.000188 |
| <font color='red'>**statistics** </font>          | 0.628449 |
| preparing            | 0.000047 |
| Creating tmp table   | 0.000075 |
| statistics           | 0.000060 |
| preparing            | 0.000014 |
| Creating tmp table   | 0.000050 |
| Sorting result       | 0.000005 |
| executing            | 0.000008 |
| Sending data         | 0.000022 |
| executing            | 0.000002 |
| Sending data         | 0.000238 |
| removing tmp table   | 0.000004 |
| Sending data         | 0.000073 |
| Creating sort index  | 0.000010 |
| end                  | 0.000001 |
| removing tmp table   | 0.000002 |
| end                  | 0.000002 |
| query end            | 0.000004 |
| closing tables       | 0.000002 |
| removing tmp table   | 0.000010 |
| closing tables       | 0.000015 |
| freeing items        | 0.000046 |
| cleaning up          | 0.000088 |


可以看到statistics所占用的时间是非常巨大的这也是这个查询非常慢的根本原因。
statistics就是说明MySQL的查询优化器在不断的向存储引擎索取统计信息以寻找最优化的查询顺序。
可以通过explain extended 的方法获取最终的执行计划。虽然执行计划已经是最优的了，但是中间的过程代价太高了。
这里就使用straight_join的优化提示来优化这个查询。由一开始的600多ms降低为十几ms了。

### 总结
1.  大的SQL语句，这里主要说的是join次数过多的sql，需要进行查询优化。
2.  尽量不要有大的SQL，大SQL对MySQL来说还是有些力不从心。
3.  straight_join 禁止了MySQL的查询优化，但是可能随着数据集的变化会有新的性能问题。因此straight_join 不能说是最终的优化方案。
4.  根据《高性能MySQL》书上的说法，分解大的查询语句能更好的利用MySQL的缓存机制，对优化大的SQL查询是首先。

所以后续查询分解是不可避免的。
