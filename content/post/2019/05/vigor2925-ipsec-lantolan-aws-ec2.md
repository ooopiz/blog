---
title: 'IPsec Lan tp Lan Vigor-2925/AWS-ec2'
date: 2019-05-17T08:02:00+08:00
draft: false
---
## 前言
簡單說一下就是，我想讓我所在的網路可以訪問到 AWS subnet 的固定子網 IP，  
內網的工作同仁或者內部 Server 不用額外做 vpn 撥號或其他動作。  
  
其實 AWS 上面也有現成的服務可以租用（在 VPC 的設定中）  
一個月大概在台幣 1,000 左右 [AWS VPN pricing](https://aws.amazon.com/tw/vpn/pricing/)。  
  
但基於我想自己架看看，另外也可以省點錢，就租了一台 EC2 來土炮了。  
  
目標就是使用 Vigor 2925 播出到 IPsec server 保持一個 Lan to Lan 的連線。  

公司端：
  
* 設備：Vigor 2925
* 網段：192.168.0.0/24

AWS 端：
  
- 網段：172.21.0.0/16
- IPsec Server ： CentOS7, EIP

## libreSwan 簡介
libreSwan 是 IPsec 協議的開源實現，基於FreeSwan 專案。  
在 Centos7 版本後， 提供ipsec 服務包由libreswan替代了openswan  

## 安裝 libreswan
```
$ yum install epel-release
$ yum install libreswan
```

## 設定 ipsec
ipsec 啟動時會載入 /etc/ipsec.conf  

`$ vi /etc/ipsec.d/ipsec.conf`

```
conn IPsec
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=tunnel
    left=172.21.2.10
    leftsubnet=172.21.0.0/16
    rightsubnet=vhost:%priv
    right=%any
```

預先共享秘鑰啟動時會載入 /etc/ipsec.secrets  

`$ vi /etc/ipsec.d/ipsec.secrets`

```
172.21.2.10 %any: PSK “pskyouwant"
```


## 修改內核參數

`vi /etc/sysctl.conf`

```
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.ip_forward = 1
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
```

額外新增一條，來符合 Aws 網卡名稱  
```
net.ipv4.conf.ens5.rp_filter=0
```
  
使配置生效  

`$ sysctl -p`

## 檢查ipsec設定

`$ ipsec setup start`
  
`$ ipsec verify`
  
如果有紅色錯誤修正一下再執行至正確狀態
  
![ipsec verify](https://fblog.loopbai.com/images/2019/05/b001.jpg "ipsec verify result")


## 開啟防火牆
可以針對欲連線的外部 IP 做白名單開放即可  
  
- udp : 500
- udp : 4500


## 啟動ipsec
```
$ systemctl start ipsec
$ systemctl enable ipsec
```

## postrouting
做完上面的步驟，應該就可以使用 IPsec 連線了，  
但如果想要訪問 IPsec 那邊的 subnet，必須在 nat 上做封包處理。  
  
aws ec2 上的網卡是 ens5 就 -o ens5
  
`$ iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o ens5 -j MASQUERADE`
  
為了避免重新開機後規則遺失，裝上 iptables-services 來管理 iptables 規則。
  
`$ yum install iptables-services`
  
儲存目前規則
  
`$ iptables-save > /etc/sysconfig/iptables`
  
啟動服務
  
```
$ systemctl start iptables
$ systemctl enable iptables
```

## Vigor 2925 設定

如下圖：

- 撥出並且永遠連線
- 撥出選 ipsec 通道，並填入 ipsec server 的 ip 位置
- 預先共用金鑰填入上方設定好的金鑰
- TCP/IP 就照你的網段進行設定吧

![Vigor lantolan](https://fblog.loopbai.com/images/2019/05/b002.jpg "vigor ipsec setting")
  
![Vigor lantolan](https://fblog.loopbai.com/images/2019/05/b003.jpg "vigor ipsec setting")

## Reference

- [IPSec 筆記](https://kkc.github.io/2018/03/21/IPSEC-note/)
- [【译】IPSEC.CONF(5) － IPsec配置](https://segmentfault.com/a/1190000000646294)
- [如何建立 Vigor3300 LAN to LAN VPN IPSec tunnel ?](https://www.draytek.com/zh/faq/faq-vpn/vpn.lan-to-lan/%E5%A6%82%E4%BD%95%E5%BB%BA%E7%AB%8B-vigor3300-lan-to-lan-vpn-ipsec-tunnel/)
