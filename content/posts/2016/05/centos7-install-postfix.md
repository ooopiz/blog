---
title: 'CentOS7 安裝Postfix'
date: 2016-05-26 10:20
draft: false
---
### Postfix介紹
Postfix 是一套快速, 安全及容易管理的開源 Mail Transfer Agent (MTA), 也是 Sendmail 很好的替代品。以下會介紹在 RHEL 及 CentOS 7 安裝 Postfix 及 Dovecot 作為 Email Server.

### 前置作業
在開始前, 如果系統內安裝了其他 MTA (例如 Sendmail 或 Exim), 那便需要將它們移除, 以下是移除 Sendmail 及 Exim 的方法:
**查詢是否安裝過**
`# rpm -qa | grep sendmail`
`# rpm -qa | grep exim`

**移除**
`# yum remove sendmail`
`# yum remove exim`

**為了使安裝過程簡單一點, 關閉 SELinux, 開啟 /etc/sysconfig/selinux, 將:**
SELINUX=enforcing
換成
SELINUX=disabled

### 1.開始安裝 Postfix
`# yum install postfix`

### 2.設定 Postfix
開啟 /etc/postfix/main.cf, 修改以下設定:

```config /etc/sysconfig/selinux
# 系統的主機名稱
myhostname = smtp.3grass.me

# email伺服器的域名
mydomain = 3grass.me

# 指定本地發送郵件中來源和傳遞顯示的域名
myorigin = $mydomain

# 設置網路介面以便Postfix能接收到郵件
# 預設值是all，如果你的機器有多張網路卡，但又不想要全部都開放 relay，就可以指定只開放給某張網路卡
inet_interfaces = all

inet_protocols = all

# 指定哪些郵件地址允許在本地發送郵件
# 這是一組被信任的允許通過伺服器發送或傳遞郵件的IP地址。用戶試圖通過發送從此處未列出的IP地址的原始伺服器的郵件將被拒絕
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain

# 受信任SMTP的列表，具體的說，受信任的SMTP客戶端允許通過Postfix傳遞郵件
# 0.0.0.0 表示不限制
mynetworks = 0.0.0.0

# 設置郵箱路徑與用戶目錄有關，也可以指定要使用的郵箱風格
home_mailbox = Maildir/
```

>mynetworks:
這可以設定成檔案的方式或是直接以IP/netmask來做設定。例如：
mynetworks=192.168.1.0/24, 127.0.0.0/8
而如果要用檔案方式：
mynetworks = 127.0.0.0/8, hash:/etc/postfix/access

>注意：
如果沒有設定mynetworks的話，記得把mynetworks_style改成host，不然同一個子網域的IP都可以透過你的機器relay信件(當然如果所有子網域的使用者你都認識的話倒還ok)
如果有設定 mynetworks_style 以及 mynetwork 時，mynetworks的設定會取代掉mynetworks_style。

**測試發信**
`# mail -s "title" ricky@mail.com <<< "bady"`

---
### SMTP防火牆設置

**25 port全部開放**
```config
-A INPUT -m state --state NEW -m tcp -p tcp --dport 25 -j ACCEPT
```

**針對部分IP做開放**
```config
-A INPUT -p TCP -s 127.0.0.0/8 --dport 25 -j ACCEPT
-A INPUT -p TCP -s 210.71.253.255 --dport 25 -j ACCEPT
```

