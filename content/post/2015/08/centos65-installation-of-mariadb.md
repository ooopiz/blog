---
title: 'CentOS6.5 安裝MariaDB'
date: 2015-08-24T07:05:01+08:00
draft: false
---
### 新增MariaDB的知識庫，讓系統使用。  
>依照自己的系統在目錄下新增檔案
>**32位元系統**

config /etc/yum.repos.d/mariadb.repo

```
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/5.5/centos6-x86
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

>64位元系統

```
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/5.5/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

### 更新套件庫
`# yum update -y`

### 安裝 MariaDB
>安裝好後啟動MariaDB，MariaDB叫做【mysql】跟MySQL的【mysqld】不一樣

`# yum install MariaDB-devel MariaDB-client MariaDB-server -y`

`# service mysql start`

`# chkconfig mysql on`

### 初始化 MariaDB
>執行這個初始化程式，過程跟MySQL一模一樣

`# /usr/bin/mysql_secure_installation`

第一個問題，Enter current password for root (enter for none):
請直接按下Enter，因為預設MariaDB沒有密碼。 

第二個問題，Change the root password? [Y/n]
是否更改root密碼，極度建議您設定root密碼，請輸入Y 

第三個問題，Remove anonymous users? [Y/n]
是否移除匿名帳號，請務必移除匿名帳號，否則別人隨便就可以進入您的資料庫了 

第四個問題，Disallow root login remotely? [Y/n]
是否移除遠端root登入權限，視需求設定 

第五個問題，Remove test database and access to it? [Y/n]
是否移除測試資料庫跟使用者，留著也沒用！移除請輸入Y 

第六個問題，Reload privilege tables now? [Y/n]
是否刷新權限表，輸入Y完成所有初始化設定！
