---
layout: post
title: 'CentOS6.5 網卡基本設定'
date: 2015-08-21 09:29
comments: true
categories: 
---
首先可以下指令顯示出所有的介面資訊
`# ip link show`

###網卡設定檔的目錄一般會在
```config /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=static
BROADCAST=192.168.1.255
IPADDR=192.168.1.2
NETMASL=255.255.255.0
NETWORK=192.168.1.0
ONBOOT=yes
```

###說明
>DEVICE 這個裝置的名稱
>BOOTPROTO 使用我們給的網路名稱（若為浮動 IP 則為 dhcp ）
>BROADCAST 這是節點的網域
>IPADDR 這是這塊網路卡的位址
>NETMASL 子遮罩網路
>NETWORK 工作的網域
>ONBOOT 開機自動開啟網路卡

在上面的例子中，我們以虛擬 IP 來作為示範，
假定這部機器的 IP 為 192.168.1.2 ，則 BROADCAST 就是 192.168.1.255 （xxx.xxx.xxx.255），
NETMASL 通常是 255.255.255.0 （與你的 IP class 有關，不過，通常我們就設成 255.255.255.0 也就是了）， 
NETWORK 就設為 192.168.1.0 (xxx.xxx.xxx.0）。
如果你的網路位址是固定的，那上面的網址就跟著改變即可！


設定玩之後，網路服務重新啓動，指令為：
`# service network restart`
