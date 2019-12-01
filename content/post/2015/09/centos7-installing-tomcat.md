---
title: 'CentOS7 安裝Tomcat'
date: 2015-09-30T06:10:01+08:00
draft: false
tags: ["centos"]
---
### 1.切換目錄到 /usr/local
我把我的tomcat放置在這裡，你也可以選擇在開心的目錄下
`# cd /usr/local`

### 2.下載Tomcat
<a href="http://tomcat.apache.org" target="_blank">Tomcat官網</a>
到官網下載你爽爽的版本
`# wget http://ftp.twaren.net/Unix/Web/apache/tomcat/tomcat-7/v7.0.57/bin/apache-tomcat-7.0.57.tar.gz`

### 3.解壓縮
`# tar -zxvf apache-tomcat-7.0.57.tar.gz`

### 4.更改資料夾名稱
`# mv apache-tomcat-7.0.57 tomcat7`

### 5.啟動或停止Tomcat
**啟動Tomcat 7**
`# /usr/local/tomcat7/bin/startup.sh`

**停止Tomcat 7**
`# /usr/local/tomcat7/bin/shutdown.sh`

### 6.防火牆設定
Tomcat 7預設連接埠為8080，所以必需開啟8080才可以連線

### 7.測試Tomcat是否正常
開啟瀏覽器，輸入【http://IP位址:8080】
<img src="//fblog.ooopiz.com/images/201509/A06-01.png">

***

若要測試範例網頁是否可以執行，輸入【http://IP:8080/examples/jsp/ 】，點選其中一個Execute即可以測試。
<img src="//fblog.ooopiz.com/images/201509/A06-02.png">
