title: "docker docker"
date: 2015-06-19 17:31:48
tags: docker
---
一直想把本地的开发环境切换到docker上，由于公司的CI出来的运行环境是docker的，所以把本地开发环境打造成docker的应该也很简单了。

首先安装虚拟机，使用Vmplayer，下载Ubuntu的安装镜像文件，安装会非常简单。接下来就是docker的安装，docker安装依照[官网](https://docs.docker.com/installation/ubuntulinux/)即可

公司的镜像是基于Ubuntu+wordpress+Apache，MySQL在宿主机上。运行container的时候带上相应的参数，这里主要是端口映射，将docker里面的80端口映射到宿主机上的某一个端口例如7080，最后运行起来类似这个样子：
```
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                                               NAMES
ff1ad6f22e91        eshop_612:latest    "/var/eshop/install/   31 hours ago        Up 31 hours         0.0.0.0:7022->22/tcp, 0.0.0.0:7080->80/tcp, 0.0.0.0:7443->443/tcp   eshop_instance_7080  
```
开始遇到一个问题就是这个端口的映射问题，起来后外部访问时还是用的宿主机的Apache，后续停掉宿主机的Apache，目的是干掉80监听端口，在docker里面增加proxy。后面就一路畅通了。

修改源码如何更新到docker里面是个麻烦的事情，如果有个外挂文件目录的功能就好了，现在只能是修改后的代码传到docker里面。其实传代码也很简单，相比以前编写C++代码，先把本地代码传到Linux服务器上进行编译，编译完再传到运行的服务器上，已经简单多了。现在做的只是把修改后的代码通过filezilla传到docker里面，然后浏览器访问就ok了。

dokcer的开发环境相对于本地的开发环境速度上有个质的飞跃，由于本地是XAMPP的，然后在windows上。很显然web的开发环境更适宜运行在docker里面了。

当然还有个非常大的优点，你可以运行任意多个container，每个container里面的code版本可以不一样啊，尤其在多版本并行开发的时候，带来的开发体验是本地不能有的。

