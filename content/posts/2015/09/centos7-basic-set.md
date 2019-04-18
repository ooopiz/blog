---
layout: post
title: 'CentOS7 基礎設定'
date: 2015-09-01 03:07
comments: true
categories: 
---
- 一、啟用網卡，停用NetworkManger
- 二、關閉SELinux
- 三、關閉UseDNS
- 四、調整時區
- 五、調整語系
- 六、修改Hostname
- 七、同步時間
- 八、停用firewalld，改用iptabless
- 九、更新一下

***

#一、啟用網卡，停用NetworkManger
先進到網卡的目錄底下，將你的網卡設定為啟動的狀態(ONBOOT=yes)

`# cd /etc/sysconfig/network-scripts`

>每台電腦的網卡名稱不一定相同

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-01.png">

`# systemctl stop NetworkManager`

`# systemctl disable NetworkManager`

`# systemctl restart network`

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-02.png">

#二、關閉SELinux
`#vi /etc/selinux/config`

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-03.png">

**這個設定reboot後才會生效**

#三、關閉UseDNS
登入SSH需要等很久的話，可以從這個設定獲得改善

`# vi /etc/ssh/sshd_config` 將 UseDNS yes 改成 no

`# systemctl restart sshd`

#四、調整時區
`# rm /etc/localtime`

`# ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime`

#五、調整語系
檢查系統目前使用的語系

`# localectl`

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-04.png">

查看系統有哪些可用的語系

`# localectl list-locales | grep zh`

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-05.png">

如果你要設定語系的話

`# localectl set-locale LANG=zh_TW.utf8`

#六、修改Hostname
**查看主機 hostname**

`# hostnamectl`

**設定 hostname**

`# hostnamectl set-hostname new_hostname`

#七、同步時間
安裝的packages

`# yum install ntp ntpdate ntp-doc`

設定開機就啟動NTP Daemon

`# systemctl enable ntpd`

系統時間與time.stdtime.gov.tw的NTP server做校時

`# ntpdate time.stdtime.gov.tw`

啟動系統的NTP Daemon

`# systemctl start ntpd`

設定要校時的NTP server

`# vi /etc/ntp.conf`

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-06.png">

#八、停用firewalld，改用iptabless
`# systemctl stop firewalld`

`# systemctl disable firewalld`

`# yum install iptables-services`

設定你的防火牆

`# vi /etc/sysconfig/iptables`

<img desc="" src="//imagehosting.rickyfun.net/201509/A01-07.png">

`# systemctl start iptables`

`# systemctl enable iptables`

#九、更新一下
送他一個

`# yum update -y`