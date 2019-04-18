---
layout: post
title: 'Yum Zabbix server, agent'
date: 2016-10-27 02:13
comments: true
categories: 
---
#### 安裝相應的 RPM 檔啟用 Zabbix Repository

***RHEL 7, CentOS 7***

`# rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/7/x86_64/zabbix-release-2.2-1.el7.noarch.rpm`

***RHEL 6, CentOS 6***

`# rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm`

## zabbix-server
>由於 Zabbix 是基於 PHP 及 MySQL 開發, 需要先安裝 LAMP 環境

***php 使用模組***

`# yum install php70w-bcmath php70w-mbstring php70w-mysql php70w-gd php70w-ldap php70w-pdo php70w-process php70w-pear php70w-xml php70w-xmlrpc`

### 開始安裝

***YUM 安裝 Zabbix 及相關套件***

`# yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway`

***建立 zabbix 帳號及資料庫***

`mysql> CREATE SCHEMA zabbix DEFAULT CHARACTER SET utf8 ;`

`mysql> GRANT ALL PRIVILEGES on zabbix.* to 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';`

`mysql> FLUSH PRIVILEGES;`

`mysql> quit`

***初始資料表匯入資料庫***

`# cd /usr/share/doc/zabbix-server-mysql-*`

`# mysql -u zabbix -p zabbix < ./create/schema.sql`

`# mysql -u zabbix -p zabbix < ./create/images.sql`

`# mysql -u zabbix -p zabbix < ./create/data.sql`

***安裝時會自動新增apache設定檔，可以檢查一下根目錄是否正確指向zabbix的網頁目錄***

`# /etc/httpd/conf.d/zabbix.conf`

```
#
# Zabbix monitoring system php web frontend
#

Alias /zabbix /usr/share/zabbix

<Directory "/usr/share/zabbix">
    Options FollowSymLinks
    AllowOverride None
    Require all granted

    <IfModule mod_php5.c>
        php_value max_execution_time 300
        php_value memory_limit 128M
        php_value post_max_size 16M
        php_value upload_max_filesize 2M
        php_value max_input_time 300
        # php_value date.timezone Europe/Riga
    </IfModule>
</Directory>

<Directory "/usr/share/zabbix/conf">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/include">
    Require all denied
</Directory>
```

***啟動***

`# systemctl start zabbix-server`

`# systemctl enable zabbix-server`

***登入頁面與預設帳密***

[http://ip-address/zabbix/](http://ip-address/zabbix/)

######   default username/password
| username | password |
|---|---|
| admin| zabbix |


***語言設置***

`# vi /usr/share/zabbix/include/locales.inc.php`

***其他路徑***

|RESOURCE|PATH|
|---|---|
|Code|/usr/share/zabbix/|
|Conf | /etc/zabbix/ |
|Log| /var/log/zabbix |

## zabbix-agent

***安裝***

`# yum install zabbix-agent`

***設定***

`# vi /etc/zabbix/zabbix_agent.conf`

***防火牆***

`iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT`

```
Server=127.0.0.1              # zibbix server 的IP
ServerActive=127.0.0.1        # zibbix server 的IP
Hostname=Zabbix server        # Client Side 主機名稱
```

***啟動***

`# systemctl start zabbix-agent`

`# systemctl enable zabbix-agent`