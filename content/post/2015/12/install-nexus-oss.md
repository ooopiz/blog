---
title: '安裝 Nexus OSS'
date: 2015-12-14T01:27:01+08:00
draft: false
---
# Nexus OSS
Nexus OSS是用來架設maven私有倉庫的好幫手
安裝其實非常容易

<a href="http://www.sonatype.org/nexus/" target="_blank">下載網址</a>

<img src="//fblog.loopbai.com/images/201512/A01-01.jpg">

### 下載至您要放置的目錄下即可開始操作以下流程(這裡放置在/usr/local)
`# tar zxvf nexus-2.11.4-01-bundle.tar.gz`

`# ln -s nexus-2.11.4-01/ nexus`

`# chown -R nexus:nexus nexus`
`# chown -R nexus:nexus nexus-2.11.4-01/`
`# chown -R nexus:nexus sonatype-work/`

修改下面兩個設定
`# vi /nexus-2.11.4-01/bin/nexus`
```config
NEXUS_HOME="/usr/local/nexus/nexus"
RUN_AS_USER=nexus
```

修改Port
`# vi /nexus-2.11.4-01/conf/nexus.properties`
``` config
application-port=18081
```


啟動
`# sh /var/opt/nexus/nexus/bin/nexus start`
