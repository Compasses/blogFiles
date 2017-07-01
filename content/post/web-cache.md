+++
author = "author"
date = "2015-11-27T17:45:24+08:00"
description = "HTTP header Cache设置"
keywords = ["web ", "cache"]
tags = ["web", "cache"]
title = "HTTP Cache"
topics = ["HTTP cache"]
type = "post"

+++

目前估计很少有网站不会使用http cache了，http cache 的合理使用能极大的提高用户体验，另一方面还能减轻server端的负担。特别现在流行https，使用好http cache也变得更加重要了。

## 相关HTTP header字段

### Last-Modified和ETag

 两者的功能类似，一个是文件的最近一次的修改时间，一个是针对这个资源文件生成的tag。都是server端的返回。刷新页面时，请求头里面会带上If-Modified-Since或者 If-None-Match。
 但是Etag并[不推荐使用](https://developer.yahoo.com/performance/rules.html#etags=)，原因就是不同的server对Etag的生成算法可能不统一，特别在集群server的情况下。

### Pragma
纯协议上的指令，对请求响应链路上的所有代理使用。例如如果pragma：no-chache，则请求在请求响应链上的任意节点都不会被缓存，因其于cache-control：no-chache意义一致。

### Expires
set response headers，对某个响应设置个超时时间，一般优先级不高，如果存在max-age的话，这个字段几乎不起作用。

### Cache-Control
public：标识验证后的respons可被缓存的。
no-store：任何情况下不缓存，并尽量不要保存到磁盘中。不缓存的资源并不能保证不被保存到磁盘中。例如浏览器的后退键，可能会导致看到过期的页面。
no-cache: 强制提交校验请求，严格模式，也即不缓存该响应。
must-revalidate: 缓存必须遵守任何的刷新规则，如果缓存超时必须重新发起请求，或者是条件请求。
proxy-revalidate： 和must 一样，只对proxy cache有效，对中间有cache server的情况，该字段指导cache server的验证方式和条件。
max-age: 指定刷新超时时间，即cache的超时时间。
s-maxage: 和 max-age一样，如果cache不是private的，他会指明cache servers使用这个s-maxage，针对public的cache有效，其会覆盖max-age。

### [vary](https://www.fastly.com/blog/best-practices-for-using-the-vary-header)
通过vary告诉http cache，寻找缓存对象时需要考虑的头域字段。比如：浏览器发了两个request，一个带有accept-encoding， 一个没有。http 缓存的时候会带上这个vary标记，表示只有带有accept-encoding的缓存对象才能是使用。达到的效果就是request里面带有accept-encoding的请求，响应缓存只能被这样的请求获取。

vary的不同会控制请求的发送数量。例如vary:*，表明每个request都是不同的。
简单的理解vary用来区分请求的差别，识别出不同的request。
vary的其他取值：user-agent, 让响应区分不同的agent；Referer, 区分这个request是从哪个页面而来。cookie, 不同认证信息不同的 request。vary指定的那些值就会影响浏览器的cache策略。

## 需要注意的几个问题
### https 证书问题
如果是无效的证书，会导致缓存无法完全起用。本地测试是doc无法被cache，静态资源还是可以的。当然这跟浏览器的行为也有关系，Firefox里面添加例外证书变成合法的就可以正常缓存了。chrome的证书比较严格不好把红叉叉去掉。
### expires和max-age 优先级问题
当response头域里面两者都包含时，浏览器会优先选用max-age，当然这是我本地的测试结果。所有的情况可能难以覆盖，比如移动端的浏览器，其他的浏览器，除了Firefox、chrome、IE等等以外的。
另外就是expires是http1.0里面的，max-age在http1.1被引入，但是[这篇文章](https://www.mnot.net/blog/2007/05/15/expires_max-age)建议最好两者都带上正确的值，或者只带上max-age。
### Conditional Requests
条件请求是当浏览器发现资源超时时，如过了max-age或者expires date，会发起条件请求，如果server发现资源变化了会回复200 ok，否则回复304的status code。正确情况下资源cache后，浏览器是不会发条件请求的，直到资源超时后。当然也不排除某些浏览器会不停的发conditional request，更为详细的介绍，[请看这里](https://greenbytes.de/tech/webdav/draft-ietf-httpbis-p4-conditional-20.html)。

## 静态资源缓存
针对静态资源，更新时更加推荐使用变更文件名的方式，例如让文件名包含一个版本号的方式。这种比文件末尾增加query string更加有效，例如有些中间proxy就不会缓存带有查询字符的url。

## PHP配合apache 实现静态资源版本控制
针对静态资源的cache设置，这个[github](https://github.com/Compasses/server-configs-apache/tree/master/src/web_performance)有较好的配置模板做参考。基本上enmod headers即可。
针对静态文件php代码里面插入版本号，一般为时间戳或者数据库里面的更新时间：
```
    /*
     * change "assert/style.css" to "assert/style.xxxx.css"
     * if change failed just return the $src
     */
    public function assert_url_version_insert($src, $version) {
        $replacement = '.'.$version.'.$1';
        $newpath = preg_replace(
            '/\.(js|css)$/',
            $replacement,
            $src
        );

        return $newpath === NULL ? $src : $newpath;
    }
```
还例如有的情况需要读取文件的修改时间作为时间戳：

```
$ftime = filectime( $filePath);
```

上面是通过读取文件的修改时间，也可以通过读取数据库的方式。
插入版本号：
```
if ($ftime) {
     $path = $this->assert_url_version_insert($path, $ftime);
}
```

这样页面加载的静态资源URL会变成：http://xxxx.xx/js/xxx.版本号.css 或者js。
Apache使能rewrite rule：
```
RewriteRule ^(.+)\.(.+)\.(js|css)$ $1.$3 [L]
```

最好再使能headers模块，针对这类静态资源设置最大缓存时间：
```
  <filesMatch "\.(css)$">
        Header merge Cache-Control "public, max-age=31104000"
    </filesMatch>
    <filesMatch "\.(js)$">
        Header merge Cache-Control "public, max-age=31104000"
    </filesMatch>
```

上述就完成了，只要后台修改了静态资源文件，则文件的名字会随着版本号的更新而更新，从而实现前端自动刷新缓存。否则这些资源文件会永远cache在客户端。超时时间为31104000s。

## 总结

1. http cache 很复杂，牵扯较多的组件，上述只是针对Apache+PHP的方案实施。
2. 没有引入更加复杂的缓存中间件，其实目前有较多的组件可直接使用的。比如[Varnish](https://www.varnish-cache.org/)如果有机会使用的话，再进行研究。
3. web 优化cache是比较重要的一环，当然还有其他的更多的零零碎碎的优化，还是需要建立在经验的基础上，多多思考这块就能不断提高了。
