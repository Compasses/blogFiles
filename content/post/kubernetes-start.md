+++
date = "2016-08-15T13:57:02+08:00"
keywords = ["docker", "kubernetes"]
tags = ["docker", "container management"]
title = "kubernetes start"
description = "k8s"
+++

先从几个概念理解开始：
## [Pods](http://kubernetes.io/docs/user-guide/pods/)
是一个container的集合，针对特定应用服务的建模，一个或者多个容器分布于相同的物理主机或者虚拟主机。位于相同pod的应用是共享存储的。容器位于相同的pod，共享IP address 和端口空间。类推到docker上，就是pod定义了一组containers。跟单个container部署类似，pods的生命周期也是跟随宿主node的。

pod建模于多个相互合作的进程，整体表现为一个内聚的service。pod作为部署的独立单位，支持水平扩张，复制等，共享各种相互依赖的资源。使用pods会有诸多好处：

1. 透明化，pod中的容器在基础框架中变得可见，为提供各种服务提供了便利。
2. 解耦，pod中的容器可以被重新构建和升级。
3. 容易使用。
4. 高性能，基础框架会统一处理容器的管理。
Pod的生命周期，通常情况下，用户不需要直接去创建pod，应该只有通过controllers RC来创建。

## RS & RC
[Replica Sets](http://kubernetes.io/docs/user-guide/replicasets/) 和 [Replication Controller](http://kubernetes.io/docs/user-guide/replication-controller/)

Replica Sets 是 Replication Controller的升级概念，共同的使命都是管理pod，让他们高可用。名字上也透漏了这一点，复制集。但是着两种东西基本都不会用，建议使用其更上层的deployment。这里还是看你的服务是通过什么方式部署的，是否通过deployment。

## [Deployment](http://kubernetes.io/docs/user-guide/deployments/)
一个Deployment提供了更新Pod和Replica Set的机制。通过Deployment可以创建新的resource和替换已有的resource。
常用的方法，更新deployment中的image，让其开始做rolling-update。deployment 是在实际使用中使用较多的API。

## [Services](http://kubernetes.io/docs/user-guide/services/)
k8s中的service是构建在Pods之上的逻辑概念。打通Pods之间的通信。service正好建模于微服务。对于Service的endpoints对应于Pods，pods通过selector 确定。

## [Resource management](http://kubernetes.io/docs/user-guide/managing-deployments/#in-place-updates-of-resources)
k8s的强大之处在于管理集群中的资源，提供了方便的接口。升级、回滚等等。链接中的命令通过kubectrl提供，可以多多操作练习。

## [Volumes](http://kubernetes.io/docs/user-guide/volumes/)
volumes提供了一种持久化数据的功能，能够跨pods使用。有很多类型的volume可用。

还有其他非常有用的概念：[Namespaces](http://kubernetes.io/docs/user-guide/namespaces/)，[Job](http://kubernetes.io/docs/user-guide/jobs/)。

## 实用操作
下面总结下平常使用较多的kubectl命令；
先看配置:
```
➜  ~ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    server: http://10.58.80.171:8080
  name: demo
- cluster:
    server: 10.58.117.209:8080
  name: dmz
- cluster:
    server: http://10.58.113.74:8080
  name: hypercd
- cluster:
    server: 10.58.113.114:8080
  name: u
contexts:
- context:
    cluster: demo
    user: ""
  name: demo
- context:
    cluster: dmz
    user: ""
  name: dmz
- context:
    cluster: hypercd
    user: ""
  name: hypercd
- context:
    cluster: u
    user: ""
  name: u
current-context: u
kind: Config
preferences: {}
users: []
```
针对哪个cluster操作就更换当前的context：
```
kubectl config use-context dmz
```
对于工作在多个cluster上的服务操作，这种方式还是比较便利的。
如何更新某个pod，例如修改了代码需要验证，不用重新部署整个cluster，只需要更新需要验证的服务即可：
```
kubectl edit deployment/crm --namespace=aw
```
namespace是用来指定namespace，edit 会打开crm 的deployment yaml 文件。修改就是拿到你的提交的image 的id，更新下image id即可。例如：
```
containers:
        image: hyper.cd/occ/bff-web:b2c232c8e088aa1d3b3320b5e4c99782e6f85b79
        imagePullPolicy: IfNotPresent
```
修改后，pods随后会被更新到最新的deployment对应的image。
k8s有UI可用的，如何拿到UI信息？可通过cluster-info获得：
```
➜  ~ kubectl cluster-info               
Kubernetes master is running at 10.58.117.209:8080
KubeDNS is running at 10.58.117.209:8080/api/v1/proxy/namespaces/kube-system/services/kube-dns
kubernetes-dashboard is running at 10.58.117.209:8080/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
grafana is running at 10.58.117.209:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
kubernetes-dashboard 便是cluster的web前端。web前端可以做各种操作，也能看到cluster的资源利用率。

describe也是个比较有用的命令，在做rolling-update的时候，可以看到具体的升级信息。

获取deployment的yaml文件：
```
kubectl get deployment/bff-web -o yaml --namespace=jq
```
可以进行修改重新deploy。

k8s作为一个开源的应用容器管理平台，已经得到了广泛的应用。看k8s的代码会是一个艰辛过程，代码量实在大，打算从kubectl入手。
kubectl 的编译只需单独编译即可，cd到src/k8s.io/kubernetes/cmd/kubectl，直接运行**go build**编译即可。就会在当前目录下生成kubectl可执行文件。cmd目录下的都可以这样build。
