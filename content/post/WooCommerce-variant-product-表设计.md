+++
author = "Jet He"
date = "2015-05-13T20:45:07+08:00"
description = "WooCommerce variant product 表设计借鉴分析"
keywords = ["MySQL"]
tags = ["MySQL"]
title = "WooCommerce variant product 表设计"
topics = ["MySQL"]
type = "post"

+++

随着功能越来越多，越来越复杂，如果数据库表设计的不好，就会遇到各种各样的问题。
目前已经发现数据表设计的非常不合理，导致出现了大量tricky的PHP代码。由于是在Wordpress平台上搭建的电商平台，免不了要借鉴下[WooCommerce](http://docs.woothemes.com/documentation/plugins/woocommerce/)的表设计了。
WooCommerce是基于Wordpress的一个插件，也能实现快速开店。下面就来分析下WooCommerce中是如何存储和组织产品数据的。在产品数据中，variant product有事最为复杂的一种。比方一件衬衫，它的variant就包含Color和Size，现就以这个例子来分析下WooCommerce中的实现。对于WooCommerce中怎么添加variant product请参照[这个链接](http://docs.woothemes.com/document/variable-product/)。但有个主意点就是添加variant product前在Product下面的Attributes tab页里面添加系统级的variants。
首先添加两个attributes分别为Color和Size，添加完后会在wp_woocommerce_attribute_taxonomies出现以下数据：


| attribute_id | attribute_name | attribute_label | attribute_type | attribute_orderby | attribute_public |
|--------------|:---------------|:---------------:|---------------:|------------------:|-----------------:|
|            4 | color          | Color           | text           | id                |                0 |
|            5 | size           | Size            | text           | id                |                0 |

<br\>

接下来去添加variant product，Color下面添加两个值：Red和Green，Size下面也增加两个值：Small和Large。添加完后会有几个表发生变化。首先，wp_terms会增加相应的variant value：

| term_id | name     | slug     | term_group |
|---|:---|:---:|---:|
|      15 | Red      | red      |          0 |
|      16 | Green    | green    |          0 |
|      17 | Small    | small    |          0 |
|      18 | Large    | large    |          0 |
|      19 | variable | variable |          0 |
<br\>
wp_term_taxonomy中新增：


| term_taxonomy_id | term_id | taxonomy     | description | parent | count |
|---|:---|:---:|---:|---:|---:|
|               15 |      15 | pa_color     |             |      0 |     1 |
|               16 |      16 | pa_color     |             |      0 |     1 |
|               17 |      17 | pa_size      |             |      0 |     1 |
|               18 |      18 | pa_size      |             |      0 |     1 |
|               19 |      19 | product_type |             |      0 |     1 |
<br\>
  其对应的term meta储存在wp_woocommerce_termmeta表中：


| meta_id | woocommerce_term_id | meta_key       | meta_value |
|---|:---|:---:|---:|
|      10 |                  15 | order_pa_color | 0          |
|      11 |                  16 | order_pa_color | 0          |
|      12 |                  17 | order_pa_size  | 0          |
|      13 |                  18 | order_pa_size  | 0          |
<br\>
现在看主表，因为创建产品的时候选择'Link all variations'，因此会产生4个SKU，post表会5条数据，但他们是自关联的，使用查询:
```
 select id, post_title, post_name, post_type, post_parent from wp_posts;
```
得到结果如下：

| id | post_title                       | post_name              | post_type         | post_parent |
|---|:---|:---:|---:|---:|
| 20 | variant product                  | variant-product        | product           |           0 |
| 21 | Variation #21 of variant product | product-20-variation   | product_variation |          20 |
| 22 | Variation #22 of variant product | product-20-variation-2 | product_variation |          20 |
| 23 | Variation #23 of variant product | product-20-variation-3 | product_variation |          20 |
| 24 | Variation #24 of variant product | product-20-variation-4 | product_variation |          20 |
<br\>
该主表对应的纵表即是这些属性的描述，产品在meta表里面存储了所有的属性序列化数组，例如id为20的是个产品，其在post_meta表中key为‘ _product_attributes’的值为所有属性描述的列表：

```
array (size=2)
  'pa_color' => 
    array (size=6)
      'name' => string 'pa_color' (length=8)
      'value' => string '' (length=0)
      'position' => string '0' (length=1)
      'is_visible' => int 1
      'is_variation' => int 1
      'is_taxonomy' => int 1
  'pa_size' => 
    array (size=6)
      'name' => string 'pa_size' (length=7)
      'value' => string '' (length=0)
      'position' => string '1' (length=1)
      'is_visible' => int 1
      'is_variation' => int 1
      'is_taxonomy' => int 1
```
即可以从产品表里面获取所有的variant值，当然需要关联上述的几个表。再如SKU的id为21的post_meta数据如下：例如SKU的id为21的post_meta数据如下：

| meta_id | post_id | meta_key               | meta_value |
|---|:---|:---:|---:|
|     295 |      21 | attribute_pa_color     | red        |
|     296 |      21 | attribute_pa_size      | small      |
|     326 |      21 | _sku                   |            |
|     327 |      21 | _thumbnail_id          | 0          |
|     328 |      21 | _virtual               | no         |
|     329 |      21 | _downloadable          | no         |
|     330 |      21 | _weight                |            |
|     331 |      21 | _length                |            |
|     332 |      21 | _width                 |            |
|     333 |      21 | _height                |            |
|     334 |      21 | _manage_stock          | no         |
|     335 |      21 | _stock_status          | instock    |
|     336 |      21 | _regular_price         | 56         |
|     337 |      21 | _sale_price            |            |
|     338 |      21 | _sale_price_dates_from |            |
|     339 |      21 | _sale_price_dates_to   |            |
|     340 |      21 | _price                 | 56         |
|     341 |      21 | _download_limit        |            |
|     342 |      21 | _download_expiry       |            |
|     343 |      21 | _downloadable_files    |            |

通过这些表的相互关联即可完整描述所有的产品。

上面分析完了WooCommerce对variant product表处理，但是实际的应用也不能完全照搬。其中产品数据表里面的default_attributs就不能满足我们的需求，需要重新加一张表做映射查询。具体就不再细说了。