---
layout: post
title: 'opensourcepos 安裝'
date: 2017-05-15 07:46
comments: true
categories: 
---

[php pos 商用版](https://phppointofsale.com/)

[開源版本 opensourcepos](https://github.com/jekkos/opensourcepos)

OpenSource POS其實就是舊版本的源碼釋出，基本上版本落差有點大，合不合用就只能試試才知道了

---

## 環境準備：
安裝lamp

php require
* php-gd
* php-bcmath
* php-intl
* php-sockets
* php-mcrypt
* php-curl installed and enabled.

## 下載程式：
`# cd /var/www`
`# git clone https://github.com/jekkos/opensourcepos.git`

`# mv opensourcepos pos`
`# cd /var/www/pos`

看你要使用哪個版本 使用git指令切過去
`# git checkout tags/3.0.2 -b b_3.0.2`


## 設置權限：
`# chown -R apache:apache /var/www/pos`

## 匯入資料：(db資訊依照自己的資訊填入)
`# mysql pos /var/www/pos/database/database.sql`

## 設定檔：
`# cd /var/www/pos/application/config`
`# cp database.php.tmpl database.php`

`# vi database.php`

```
$db['default']['hostname'] = 'localhost';
$db['default']['username'] = 'db_user';
$db['default']['password'] = 'db_pass';
$db['default']['database'] = 'pos';
```

## apache設定
`vi /etc/httpd/conf.d/pos.conf`

```
<VirtualHost *:80>
DocumentRoot /var/www/pos/public
  <Directory /var/www/pos>
    DirectoryIndex index.php index.html
    Options FollowSymLinks MultiViews ExecCGI
    AllowOverride All
    Order deny,allow
    Allow from all
  </Directory>
</VirtualHost>
```

## 登入畫面
帳號：admin
密碼：pointofsale
<img src="//imagehosting.rickyfun.net/2017/m05-a01.jpg">


## 登入成功畫面
<img src="//imagehosting.rickyfun.net/2017/m05-a02.jpg">

## 切換語系
<img src="//imagehosting.rickyfun.net/2017/m05-b01.jpg">