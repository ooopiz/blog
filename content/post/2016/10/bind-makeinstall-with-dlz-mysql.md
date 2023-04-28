---
title: 'bind make安裝搭配 dlz mysql'
date: 2016-10-17T15:46:01+08:00
draft: false
tags: ["dns", "bind"]
---

## Bind-dlz 簡介

1. BIND從文本文件中獲取數據，這樣容易因為編輯錯誤出現問題。
2. BIND需要將數據載入到內存中，如果域或者記錄較多，會消耗大量的內存。
3. BIND啟動時解析Zone文件，對於一個記錄較多的DNS來說，會耽誤更多的時間。
4. 如果最近修改一條記錄，那麼要重新載入或者重啟BIND才能生效，可能會影響客戶端查詢。
5. bind-dlz主要解決上述缺陷而誕生，在mysql存儲zone的記錄，比在文本中好管理的多。
6. DLZ算是bind的好朋友，用了DLZ後，這些zone記錄可以直接存到資料庫(mysql PostgreSQL等)並且是立即生效

## Reference
- [智能DNS(Bind dlz)在企業中的應用](http://www.coctec.com/docs/service/show-post-12776.html)

## Bind 安裝 (MySQL篇)

bind9 默認不支援 dlz 需要在編譯時加上 with (看你搭配什麼資料庫)
  
* --with-dlz-mysql
* --with-dlz-postgres

### 前置作業

一、到官網或FTP站下載安裝檔
  
- [Bind官網](https://www.isc.org/downloads/)
- [FTP站](http://ftp.isc.org/isc/bind9/)
  
二、安裝MySQL資料庫

### 開始安裝

#### 1. 防火牆設定(開啟 53 port)

`iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 53 -j ACCEPT`
  
`-A INPUT -p udp -m state --state NEW -m udp --dport 53 -j ACCEPT`
  
`service iptables save`
  
`service iptables restart`

#### 2. 移除舊有的bind安裝

`rpm -qa | grep "^bind"`
  
`yum remove bind`

#### 3. 安装依賴套件

`yum install gcc openssl openssl-devel mysql-devel`

#### 4-1. 編譯with mysql

`./configure --prefix=/usr/local/bind9 --enable-threads --with-libtool --with-openssl=yes --enable-exportlib --with-dlz-mysql --enable-largefile`

#### 4-2. 編譯with postgres

`./configure --prefix=/usr/local/bind9 --enable-threads --with-libtool --with-openssl=yes --enable-exportlib --with-dlz-postgres`

##### 編譯配置項說明(完整的功能配置項可使用: ./configure --help 查看):

| 參數 | 說明 |
|---|---|
| --prefix=/usr                  |   bind安裝路徑, 默認[ /usr/local ]
| --sysconfdir=/etc          |   配置文件路徑, 默認 [ /etc ]
| --enable-threads           |   激活多線程
| --with-libtool                  |   Use GNU libtool
| ---with-openssl=yes     |   Build with OpenSSL yes|no|path. (Required for DNSSEC)
| --enable-exportlib         |   Build exportable library (GNU make required) [default=no]
| --with-dlz-postgres       |   使用postgres驅動，可以指定include檔路徑，<br />例：--with-dlz-postgres=/usr/local/pgsql/include
| --with-dlz-mysql            |   使用mysql驅動，需要mysql的類庫及頭文件支持，需要先安裝mysql，<br />可以指定include檔路徑，例：--with-dlz-mysql=/www/include

#### 5. 編譯安裝

`make`
  
`make install`

#### 6. 設定

`vi named.conf`
  
```
options {
    listen-on port 53 { any; };
    listen-on-v6 port 53 { ::1; };
    allow-query     { any; };

    allow-transfer { none; };
    allow-update { none; };
    allow-recursion { none; };
    recursion no;

    version "zzz";
};

logging {
    channel default_debug {
        file "var/bind9.log" versions 3 size 10m;
        severity dynamic;
        print-time yes;
        print-severity yes;
    };
};

include "etc/bind.keys";

dlz "mysql zone" {
    database "mysql
      {host=localhost dbname=dns_data ssl=false port=3306 user=admin pass=admin}
      {select zone from dns_records where zone='$zone$' limit 1}
      {select ttl, type, mx_priority, data, resp_person, serial, refresh,
retry, expire, minimum from dns_records where zone ='$zone$' and host = '$record$'}";
};
```

#### 7. 創建named用戶與群組

`groupadd named`
  
依據你的目錄建立用戶
  
`adduser -d /var/named -g named -s /bin/false named`
  
`adduser -d /usr/local/bind9 -g named -s /bin/false named`
  
|參數|說明|
|---|----|
| -d | 被創建的named用戶的主目錄 |
| -g | 所屬群組 |
| -s | 帳號的登入shell(false表示不能登入) |
  
給予目錄權限
  
`chown -R named:named ./var`

#### 8. 資料庫中建立Schema and Record

##### Schema Example
  
```sql
CREATE DATABASE  IF NOT EXISTS `dns_data`;
USE `dns_data`;

CREATE TABLE `dns_records` (
  `ser_no` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zone` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `data` varchar(255) DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `mx_priority` int(11) DEFAULT NULL,
  `refresh` int(11) DEFAULT NULL,
  `retry` int(11) DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `minimum` int(11) DEFAULT NULL,
  `serial` bigint(20) DEFAULT NULL,
  `resp_person` varchar(255) DEFAULT NULL,
  `primary_ns` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ser_no`),
  KEY `host_index` (`host`(20)) USING BTREE,
  KEY `type_index` (`type`(8)),
  KEY `zone_index` (`zone`(30))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `xfr_table` (
  `zone` varchar(255) NOT NULL,
  `client` varchar(255) NOT NULL,
  KEY `zone_client_index` (`zone`(30)),
  KEY `client_index` (`client`(20))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

```

##### Record Example

```sql
INSERT INTO `dns_records`
( `zone`, `host`, `type`, `data`, `ttl`, `mx_priority`, `refresh`, `retry`, `expire`, `minimum`, `serial`, `resp_person`, `primary_ns`)
VALUES
/* SOA */
('example.com','@','SOA','ns1.example.com.',3600,NULL,10800,7200,604800,86400,2015091101,'master.example.com.','ns1.example.com.'),
('example.com','@','NS','ns1.example.com.',3600,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('example.com','ns1','A','192.168.0.1',3600,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),

/* A AAAA CNAME Record */
('example.com','@','A','127.0.0.1',3600,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('example.com','@','AAAA','::1',3600,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('example.com','www','CNAME','@',3600,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),

```

#### 9. 啟動

`sbin/named -c etc/named.conf -u named` 

## 其他指令參考

檢查設定檔

`sbin/named-checkconf etc/named.conf`

啟動

`sbin/named`

啟動(使用named身份執行)

`sbin/named -u named`

啟動(前台執行，會輸出啟動訊息，debug可以使用)

`# sbin/named -g`

啟動(指定設定檔)

`/usr/local/bind9/sbin/named -c /usr/local/bind9/etc/named.conf` 

## 疑難排解

### 一、找不到mysql.h時

`yum install mysql-devel`

### 二、如果抓不到/usr/lib/mysql

編譯加上
  
```
--with-mysql-libraries=/usr/lib64/mysql/
```

### 三、(承二)但是也有可能無效，死都要抓/usr/lib/mysql，只好做一個軟鍊給他

`ln -s /usr/lib64/mysql/ /usr/lib/mysql`

## 其他

### 生成rndc key
`sbin/rndc-confgen -a -r /dev/urandom`

### 更新named.ca

頂級域名伺服器地址有所變動，dns 伺服器需要更新 named.ca 文件

最新資訊可以到 [ftp://rs.internic.net/domain](ftp://rs.internic.net/domain) 下載。

### dlz官方提供zone for mysql
  
```
dlz "mysql zone" {
   database "mysql
      {host=localhost dbname=dns_data ssl=false port=3306 user=admin pass=admin}
      {select zone from dns_records where zone='$zone$' limit 1}
      {select ttl, type, mx_priority, data, resp_person, serial, refresh,
retry, expire, minimum from dns_records where zone ='$zone$' and host = '$record$'}";
};
```

## DNS security reference
- [DNS伺服器安全性管理實務](http://www.lijyyh.com/2012/07/dns-dns-server-security-management.html)
- [Study DNS-DNS 進階設定、安全、檢測](http://wiki.weithenn.org/cgi-bin/wiki.pl?Study_DNS-DNS_%E9%80%B2%E9%9A%8E%E8%A8%AD%E5%AE%9A%E3%80%81%E5%AE%89%E5%85%A8%E3%80%81%E6%AA%A2%E6%B8%AC)
- [建議安裝 fail2ban來阻擋](https://dotblogs.com.tw/jerrymow/2013/04/25/102283)
