---
title: 'VirtureBox網卡設定 - 讓虛擬機器可以連外同時本機可以連虛擬機器'
date: 2015-09-09T09:10:01+08:00
draft: false
---
VirtualBox透過NAT網卡來達到對外部的連線
當你本機想要跟虛擬機器進行連線的時候，你可以建立一個區域網路來進行連線

***

Windows環境在你安裝VirtualBox的時候就幫你安裝了一個網路配接卡
Mac就必須自己手動新增一下

VirtualBox->喜好設定
<img src="//imagehosting.rickyfun.net/201509/A03-01.png">

***

###設定2張介面卡
**1. NAT**
<img src="//imagehosting.rickyfun.net/201509/A03-02.png">

**2. 僅限主機介面卡**
<img src="//imagehosting.rickyfun.net/201509/A03-03.png">

<b style="color:red;">VirtualBox 的 Host Only 網卡的預設網段是 192.168.56.0</b>
<img src="//imagehosting.rickyfun.net/201509/A03-04.png">
