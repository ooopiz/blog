---
title: "Docker cli 連線到遠端的 dockerd daemon"
date: 2019-06-04T20:22:08+08:00
draft: false
tags: ["docker"]
---
## docker 是 client/server 的架構
昨天在網路上看到一句話，大意是：

> docker 是 client / server 的架構，
> 由一個 docker cli 和 dockerd 的 daemon 組成

才赫然發現 docker 別有洞天吶。  
原來每天在敲的 docker 指令都是在操控本機的 docker daemon。  

## 如何連線到遠端的 docker daemon
有了上面那句話，就在想說是不是可以用我 local 的 docker cli 連線到其它機器的 dockerd。  

今天馬上用我 virtualbox 中的 coreOS 進行測試一下。

### dockerd port listen
dockerd default 好像都沒有開啟 tcp port，必須在 dockerd 啟動時加入 -H 參數。

`-H tcp://0.0.0.0:2375`

如果是用 systemctl 控制 docker 你可以找到 docker.service，在腳本中加入 -H 參數。

以 coreOS 為例，  
我的檔案在 /run/systemd/system/docker.service  

![dockerd -H tcp://0.0.0.0:2375](https://fblog.ooopiz.com/images/2019/06/a001.jpg "docker -H tcp://0.0.0.0:2375")

修改完後，reload 並重啓

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

接著就可以看到 service 的 port 已經打開了。

![dockerd port listen](https://fblog.ooopiz.com/images/2019/06/a002.jpg "dockerd prot listen")

### 連線測試
一般我們 key 入 docker version，就可以看到一個 Client，一個 Server.  

現在改輸入 docker -H tcp://remote_ip:port version  
一樣是一個 Client 一個 Server，注意看會發現 Server 那邊的資訊已經不一樣了。  
說明指令已經控制到遠端的 docker 了。

![docker connecting remote daemon](https://fblog.ooopiz.com/images/2019/06/a003.jpg "docker connecting remote daemon")

你可以在試試看下面這些指令，你應該可以發現不同了。(記得換成你在用的 IP)
```
$ docker -H tcp://192.168.56.101:2375 images
$ docker -H tcp://192.168.56.101:2375 ps
$ docker -H tcp://192.168.56.101:2375 ps -a
```

每次都要打 -H 也是蠻煩的。你也可以

```
$ export DOCKER_HOST="tcp://192.168.56.101:2375"
$ docker version
```

## Reference
- [Docker Tip #73: Connecting to a Remote Docker Daemon](https://nickjanetakis.com/blog/docker-tip-73-connecting-to-a-remote-docker-daemon)
- [docs.docker.com](https://docs.docker.com/engine/reference/commandline/dockerd/)

