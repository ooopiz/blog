---
layout: post
title: 'CentOS yum 安裝bind9'
date: 2016-10-04 02:09
comments: true
categories: 
---
## 安裝

`# sudo yum install bind bind-utils -y`

`# service named start`

`# chkconfig named on`


#### 防火牆設定

`# iptables -I INPUT 5 -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT `

`# iptables -I INPUT 5 -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT`

`# service iptables save`

`# service iptables restart`


## 設定

### 預設nemed.conf檔 (BIND 9.8.2rc1-RedHat-9.8.2-0.47.rc1.el6)
###### 以下為yum安裝後產生的預設named.conf設定檔

```
options {
        listen-on port 53 { 127.0.0.1; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { localhost; };
        recursion yes;

        dnssec-enable yes;
        dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

### 修改設定
###### 修改options設定，允許查詢來源

`# vi /etc/named.conf`

```
options {
        //(其他參數略...)
        listen-on port 53 { any; };
        listen-on-v6 port 53 { any; };
        allow-query { any; };
        version "zzz";
};
```

### 新增正解設定檔

`# vi /etc/named.conf`

```
zone  "example.com" {
        type master;
        file  "forward.example.com.zone";
};
```

###### named.conf中指example.com的域名zone檔，因此必須在預設根目錄(/var/named)的路徑新增一個檔案

`# vi /var/named/forward.example.com.zone`

```
; zone file for example.tld
$TTL 1200     ; 14400 4 hours - default TTL for zone
$ORIGIN example.com.
;; SOA Resource Record
@             IN      SOA   ns1.example.com. hostmaster.exapmle.com. (
                        2015010100 ; se = serial number
                        12h        ; ref = refresh
                        15m        ; ret = update retry
                        3w         ; ex = expiry
                        3h         ; min = minimum
                        )
;; Name Servers
              IN      NS      ns1.exapmle.com.
ns1           IN      A       192.168.0.1
;; Web Server Resource Records
@             IN      A       192.168.0.2
www           IN      CNAME   @
@             IN      AAAA    2001:b034:2000:1000:1000::38
;; FTP Server Resource Records
ftp           IN      A       192.168.0.3
```

### 指令

##### 檢查設定檔(可以用以下指令來檢查設定是否正確)

`# named-checkconf /etc/named.conf`

## 查bind版本

### 方法一

`# nslookup -debug -class=chaos -query=txt version.bind <NameServer IP>`

<img desc="" src="//imagehosting.rickyfun.net/201609/A02-02.jpg">

### 方法二

`# dig @<NameServer IP> version.bind chaos txt`

<img desc="" src="//imagehosting.rickyfun.net/201609/A02-01.jpg">

##### 隱藏版本資訊

```
options {
        //(其他參數略...)
        version "ZZZ";
};
```
