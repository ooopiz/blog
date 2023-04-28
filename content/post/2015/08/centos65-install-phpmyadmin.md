---
title: 'CentOS6.5 安裝phpMyAdmin'
date: 2015-08-24T02:00:01+08:00
draft: false
tags: ["phpmyadmin"]
---
## 一、安裝phpMyAdmin

phpMyAdmin 對應 php 版本會有影響，請挑選適合的版本

`wget http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.1.12/phpMyAdmin-4.1.12-all-languages.tar.gz`

`tar -zxvf phpMyAdmin-4.1.12-all-languages.tar.gz`

`mv phpMyAdmin-4.1.12-all-languages /usr/share/nginx/html/phpMyAdmin`

`rm phpMyAdmin-4.1.12-all-languages.tar.gz`

## 二、設定config.inc.php

路徑:/usr/share/nginx/html/phpMyAdmin  
複製範本設定檔 config.sample.inc.php 並重新命名為 config.inc.php

`cp config.sample.inc.php config.inc.php`

```
 /* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'cookies';
```

改成

```
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'http';
```

![](https://fblog.ooopiz.com/images/201508/A01-01.png)

## 三、查看mysql使用者,新增使用者,給予權限

`mysql -u root -p -h 127.0.0.1`

`mysql> select user, host from mysql.user;`

![](https://fblog.ooopiz.com/images/201508/A01-02.png)

`mysql> create user 'admin'@'%' identified by 'admin';`

![](https://fblog.ooopiz.com/images/201508/A01-03.png)

`mysql> grant all on *.* to 'admin'@'%';`

這樣 admin 對整個資料庫的所有資料表都擁有全部的權利

![](https://fblog.ooopiz.com/images/201508/A01-04.png)

## 四、phpMyAdmin 高級功能啟用

![](https://fblog.ooopiz.com/images/201508/A01-05.png)

* 建立使用者pma  
  `mysql> create user 'pma'@'localhost' identified by 'pmapass';`
* 給予pma表phpmyadmin權限  
  `mysql> grant select, insert, update, delete on phpmyadmin.* to pma@localhost;`

![](https://fblog.ooopiz.com/images/201508/A01-06.png)

* 執行create_tables.sql啟用高級功能  
  `mysql -u root -p < /usr/share/nginx/html/phpMyAdmin/examples/create_tables.sql`

![](https://fblog.ooopiz.com/images/201508/A01-07.png)

* 編輯 config.inc.php 設定檔,將下列的部分註解拿掉

![](https://fblog.ooopiz.com/images/201508/A01-08.png)

## 五、完成，即可在phpMyAdmin看到表phpmyadmin

![](https://fblog.ooopiz.com/images/201508/A01-09.png)
