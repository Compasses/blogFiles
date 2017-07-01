+++
author = "author"
date = "2015-12-09T21:48:04+08:00"
description = "Apache的Cache配置"
draft = false
keywords = ["web cache", "Apache cache"]
tags = ["web", "cache"]
title = "Apache Cache 研究"
topics = ["Web"]
type = "post"

+++

Apache 作为一个hosting server，在2.2版本以上的也有较为强大的缓存功能。使其不管是作为web server还是代理server都能实现访问加速。
Apache支持两种cache模块，分别是mod_cache和mod_file_cache。mod_file_cache较为简单粗暴，cache那种不轻易改变的或者对实效性要求不高的文件较为适合，因为后台更新了缓存不能及时更新，需要一个周期或者重启Apache。
mod_cache是一种较为智能有效的、感知HTTP协议的cache方式，它有两种实现方案mod_mem_cache和mod_disk_cache，顾名思义mem是将响应内容缓存到内存中，disk是将响应内容缓存到磁盘中。mem是代价比较高的，因其缓存到内存中就会不可避免的导致Apache占用的系统内存增加。因此disk的缓存方案多被推荐使用。
具体详细的信息可以参考Apache的官方文档[Caching Guide](http://httpd.apache.org/docs/2.2/caching.html#inmemory)

## 浏览器刷新原则
不同的请求header，cache的响应行为是不一样的，所以要搞清楚你的请求header是什么样的，响应header是什么样的，搞清楚才能较好的测试Apache的cache。
这里使用的测试浏览器是Firefox，也推荐使用Firefox，禁止Firefox的本地cache。
一般的请求头，类似点击页面链接：

```
Accept text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Encoding gzip, deflate
Accept-Language zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3
Connection keep-alive
Cookie  timeOffset=-480; timeOffset=-480; wp-settings-time-1=1445853102; PHPSESSID=ohiq63apsjmvsrl443778j22g6; ANW_TRACE_ID=25a6e917-0a0b-4580-a989-14ef71368ea1; CART_ITEMS=%5B%5D
Host 10.128.163.72
User-Agent Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0

```
F5 刷新的请求头：
```

Accept text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Encoding gzip, deflate
Accept-Language zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3
Cache-Control max-age=0
Connection keep-alive
Cookie timeOffset=-480; timeOffset=-480; wp-settings-time-1=1445853102; PHPSESSID=ohiq63apsjmvsrl443778j22g6; ANW_TRACE_ID=25a6e917-0a0b-4580-a989-14ef71368ea1; CART_ITEMS=%5B%5D
Host  10.128.163.72
User-Agent  Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0
```
注意两者的变化，F5刷新时，请求头里面多了 Cache-Control 的域，max-age 赋值为0，这就告诉所有的后续服务器如果缓存了这个资源请尝试更新。不出意外后续的服务器会针对这个请求发 Conditional Requests，后台服务器验证资源的有效性，如果过期则返回200 ok，否则返回304 not modified。

Ctrl + F5 刷新页面的请求头：
```

Accept
text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Encoding
gzip, deflate
Accept-Language
zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3
Cache-Control
no-cache
Connection
keep-alive
Cookie
timeOffset=-480; timeOffset=-480; wp-settings-time-1=1445853102; PHPSESSID=ohiq63apsjmvsrl443778j22g6; ANW_TRACE_ID=25a6e917-0a0b-4580-a989-14ef71368ea1; CART_ITEMS=%5B%5D
Host
10.128.163.72
Pragma
no-cache
User-Agent
Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0
```
注意这个请求头的新变化，又增加了一个新头域Pragma 值为 no-cache，Pragma 是HTTP1.0 里面定义的，Cache-Control 是HTTP1.1里面定义的，两个头域就足以保证了这个请求无法从cache中获取，直接强制性的去后台服务器发起获取。

以上三种不同的请求头会使得cache服务器的有着完全不同的行为。

## 实施Apache缓存
因Apache官方也是推荐使用mod_cache+mod_disk_cache的方式，所以这里实施的也是这种方式。Apache默认这两个mod都是安装好的，直接起用就好了：
```
$ sudo a2enmod cache
$ sudo a2enmod cache_disk
```
cache_disk的配置项：
```
<IfModule mod_cache.c>
<IfModule mod_cache_disk.c>
        CacheRoot /var/cache/apache2/mod_cache_disk
        # This will also cache local documents. It usually makes more sense to
        # put this into the configuration for just one virtual host.
        CacheEnable disk /wp-content/

    CacheDirLevels 2
    CacheDirLength 1

    CacheLock on
    CacheLockPath /tmp/mod_cache-lock
    CacheLockMaxAge 5

</IfModule>
</IfModule>
```
CacheRoot 是cache文件的保存位置，需要注意的是CacheEnable后面的url，指定了要cache 的url路径，既是从域名的开始路径位置，上面的配置会缓存http://xxxx/wp-content/ 开始的请求。
CacheLock 配置是为了防止大量的资源刷新请求造成的[资源“群涌”现象](http://httpd.apache.org/docs/2.2/mod/mod_cache.html#thunderingherd)，避免对后台server造成严重的冲击。

配置Apache的log level为debug，可以 对的cache 执行结果检查。

## cache效果检查
按照上述配置Apache后，重启Apache。访问静态资源，注意不是刷新或者强制刷新。查看Apache的error log。
例如能看到如下内容：
```
[Wed Dec 09 11:14:50.817537 2015] [cache:debug] [pid 10424] mod_cache.c(636): [client 10.128.161.107:56600] AH00763: cache: running CACHE_OUT filter
[Wed Dec 09 11:14:50.817543 2015] [cache:debug] [pid 10424] mod_cache.c(665): [client 10.128.161.107:56600] AH00764: cache: serving /wp-content/templates/halloween/assets/css/style.css
```
cache serving 表明该请求是从Apache缓存中返回的。浏览器中是否可以看到该请求是从Apache cache返回的呢，当然是可以的：
```

Accept-Ranges
bytes
Age
2379
Cache-Control
public, max-age=31104000
Connection
Keep-Alive
Content-Encoding
gzip
Content-Length
5901
Content-Type
text/css
Date
Wed, 09 Dec 2015 09:22:39 GMT
Etag
"7071-52671bdf81d18-gzip"
Keep-Alive
timeout=5, max=100
Last-Modified
Wed, 09 Dec 2015 07:07:23 GMT
Server
Apache/2.4.7 (Ubuntu)
Vary
Accept-Encoding
```
看这个响应头里面的Age字段，如果不是从cache出去的话是没有这个Age字段的，Age的值是记录的这个资源当前的缓存时间单位为秒，每次请求这个字段都是会增加的。

## cache的资源副本
Apache的cache根据响应头的Vary域来决定cache的资源被相应的client请求使用。HTTP头域中的Vary本来就是用来标识不同的客户端即不同的浏览器。
这个问题可以通过Firefox和chrome来验证，例如请求一个静态资源文件，都会带上```Accept-Encoding```，响应头Vary域则是：```Vary: Accept-Encoding```。
如果两个客户端的请求头里面的Accept-Encoding是不一样的，则cache服务会根据不同的Vary头选择相应的缓存内容。也就是说明具有不同Accept-Encode的客户端浏览器缓存的内容是不一样的。
也即相同的URL会有不同的缓存副本。

当你看到不同的浏览器拿到的响应头里面的 Age 大小不一致时，就不用大惊小怪了，因为他们是不同的缓存副本。

## 缓存资源的更新周期
使用Apache的缓存后，资源被缓存到disk上后，资源的更新首先由HTTP 的header字段决定，例如上面的响应头里面，那么这个资源的超时时间为max-age=31104000秒。
如果Cache-Control没有指定则会根据Last-Modified时间计算得出，具体如何计算可以参考[官方文档](http://httpd.apache.org/docs/2.2/mod/mod_cache.html#cachelastmodifiedfactor)。如果响应头里面也没有modify time，则会使用个默认的cache时间，当然这个可以[自己配置任意时间](http://httpd.apache.org/docs/2.2/mod/mod_cache.html#cachemaxexpire)。
Apache只管缓存，缓存文件的清理需要借助一个deamon进程：htcacheclean。
下面命令表示每个60分钟，清理缓存一次，只清理过时的或最少使用的缓存，达到100M时也会清理缓存。
```
htcacheclean –d60 -n -t -p/var/cache/apache2/mod_cache_disk -l100M –i
```

但是针对于那种需要及时更新的资源，需要另外的手段保证浏览器能够拿到最新的资源。[上一篇笔记里面的方法能较好](http://compasses.github.io/2015/11/27/http-cache/)的解决这个问题，
