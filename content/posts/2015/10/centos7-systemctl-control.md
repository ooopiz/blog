---
title: 'CentOS7 Tomcat增加systemctl控制'
date: 2015-10-01T05:24:01+08:00
draft: false
---
#1.增加啟動參數
在Tomcat的bin目錄下增加一個setenv.sh檔，catalina.sh啟動的時候會調用，同時可以在這個檔案設置Java內存

**範例如下:**
```config setenv.sh
#add tomcat pid  
CATALINA_PID="$CATALINA_BASE/tomcat7.pid"  
#add java opts  
JAVA_OPTS="-server -XX:PermSize=256M -XX:MaxPermSize=1024m -Xms512M -Xmx1024M -XX:MaxNewSize=256m"
```

#2.增加tomcat.service
在/usr/lib/systemd/system目錄下增加tomcat7.service，內容的目錄必須是絕對路徑。
`# vi /usr/lib/systemd/system/tomcat7.service`

PIDFile就指到tomcat所在的目錄

```config tomcat7.service
Description=Tomcat  
After=syslog.target network.target remote-fs.target nss-lookup.target  
   
[Service]  
Type=forking  
PIDFile=/data/tomcat/tomcat7.pid  
ExecStart=/data/tomcat/bin/startup.sh   
ExecReload=/bin/kill -s HUP $MAINPID  
ExecStop=/bin/kill -s QUIT $MAINPID  
PrivateTmp=true  
   
[Install]  
WantedBy=multi-user.target 
```

>[unit]設定服務的描述
>[service]設定服務的啟動，停止等
>[install]設定使用用戶

***

查看全部服務：
systemctl list-unit-files --type service
查看服務
systemctl status name.service
啟動服務
systemctl start name.service
停止服務
systemctl stop name.service
重啟服務
systemctl restart name.service
增加開機自動啟動
systemctl enable name.service
刪除開機自動啟動
systemctl disable name.service

.service 可以省略
