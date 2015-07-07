title: "Nginx + Docker Cluster & session sticky"
date: 2015-07-06 17:32:41
tags: "Ngnix"
---

##基本配置
本地开发环境和生产环境还是有很大的区分，最近性能测试发现结果很不好，于是想自己去搭建一个类似生产环境的性能测试环境。

由于前期已经有了docker的开发环境，这里只需要增加Nginx 作为反向代理。
在/etc/nginx/conf.d目录下新建文件例如proxyServer.conf，添加如下内容

```
## Basic reverse proxy server ##
upstream dockerServer  {
    ip_hash;
    server 10.128.163.121:7080;
    server 10.128.163.121:17080;
}

upstream dockerServerSSL  {
    ip_hash;
    server 10.128.163.121:7443;
    server 10.128.163.121:17443;
}

server {
    listen 80;
    server_name  10.128.163.121;

    ##access_log  logs/60.access.log  main;
    error_log  logs/60.error.log;
    root   html;
    index  index.html index.htm index.php;

    ## send request back to apache ##
    location / {
        proxy_pass  http://dockerServer ;

        #Proxy Settings
        proxy_redirect     off;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_max_temp_file_size 0;
        proxy_connect_timeout      90;
        proxy_send_timeout         90;
        proxy_read_timeout         90;
        proxy_buffer_size          4k;
        proxy_buffers              4 32k;
        proxy_busy_buffers_size    64k;
        proxy_temp_file_write_size 64k;
   }
}
server {
    listen 443;
    server_name  10.128.163.121;
    ssl on;
    ssl_certificate /etc/nginx/conf.d/server.crt;
    ssl_certificate_key /etc/nginx/conf.d/server.key;

    ##access_log  logs/60.access.log  main;
    error_log  logs/60.error.log;
    root   html;
    index  index.html index.htm index.php;

    ## send request back to apache ##
    location / {
        proxy_pass  https://dockerServerSSL ;

        #Proxy Settings
        proxy_redirect     off;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_max_temp_file_size 0;
        proxy_connect_timeout      90;
        proxy_send_timeout         90;
        proxy_read_timeout         90;
        proxy_buffer_size          4k;
        proxy_buffers              4 32k;
        proxy_busy_buffers_size    64k;
        proxy_temp_file_write_size 64k;
   }
}
```

注意点：
1. https需要单独配置，由于后端server在https下也要工作，因为某些页面安全性要求较高，需要转成https的。
2. 这里使用的是ip_hash的方式做负载均衡，但是也有一定的缺陷，即在代理访问的情况下客户端ip有可能是会发生改变的，还有就是ip在负载均衡上均衡比较困难。
3. https的crt和key需要[自己生成](http://www.lovelucy.info/nginx-ssl-certificate-https-website.html)。
另外这个Nginx 是跑在宿主机上的，修改配置有要执行reload命令使其生效。

##session persistence
生产环境需要将一个用户的请求要路由到同一个server上面，因为server很多的业务处理还是需要server里面的session配合。上面用ip_hash方式做load balance，但是考虑到用户使用proxy或者流量不均衡等因素。还是要使用session sticky的方式。
Nginx默认不支持session sticky，需要重新编译安装这个插件；因为直接使用公司的Nginx版本，所以懒得重新编译了。使用很简单，直接拷贝个bin文件，然后修改成这个样子：

```
upstream dockerServer  {
      sticky name=yourname httponly path=/ hash=md5;
       server 10.128.163.121:17080;
       server 10.128.163.121:7080;
   }
   
  upstream dockerServerSSL  {
     sticky name=yourname httponly path=/ hash=md5;
     server 10.128.163.121:17443;
     server 10.128.163.121:7443;
 }
 ```

这样直接访问 http://10.128.163.121 即可，Nginx会自动路由请求到某一个server上。因为sticky是会话级别的，关掉浏览器会话就结束了。如果重新访问用户可能会被路由到另一个server上，可以通过查询Apache的accesslog来确认。

