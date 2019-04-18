---
layout: post
title: 'HP ProLiant DL20 Gen9 CentOS7 安裝讀不到Raid卡解決方式'
date: 2016-09-29 08:49
comments: true
categories: 
---
<img desc="" src="//imagehosting.rickyfun.net/201609/A04-01.jpg">


原生的CentOS iso檔無法讀到機器的Raid卡，需要自行下載驅動來安裝．

首先必須先準備CentOS7的安裝檔，並且下載相對應的驅動，方法如下

##### * RECOMMENDED * HP ProLiant Smart Array 控制器 (AMD64/EM64T) 驅動程式磁碟（適用於 Red Hat Enterprise Linux 7 (AMD64/EM64T)）

- [hpsa-3.4.10-120.rhel7u0.x86_64.dd.gz](https://drive.google.com/file/d/0Bxjw3Y-ONcPtUkRBaVdBYUdZenM/view?usp=sharing) << CentOS 7
- [hpsa-3.4.10-120.rhel7u1.x86_64.dd.gz](https://drive.google.com/file/d/0Bxjw3Y-ONcPtajJ0SU03ckh5emM/view?usp=sharing) << CentOS 7.1


### CentOS 7版本說明
| RHEL 版本|  版本 |
|---|---|
|CentOS 7     |  7-1406  |
|CentOS 7.1  |  7-1503  |
|CentOS 7.2  |  7-1511  |

[Wiki - CentOS版本說明](https://zh.wikipedia.org/wiki/CentOS)

Installation:

- 在類似 Linux 的作業系統下建立驅動程式更新 USB 隨身碟：
- 將 hpsa-..x86_64.dd.gz 檔案儲存至暫存目錄。使用 GUNZIP 將此檔案中的 hpsa-..x86_64.dd 解壓縮至同一目錄。
- 插入 USB 隨身碟。若已自動掛載 USB 隨身碟，請卸載 USB 隨身碟。
- 寫入 hpsa-..x86_64.dd 檔案至 USB 隨身碟裝置。(不包括 USB 隨身碟是 /dev/sdc)
`dd if=hpsa-..x86_64.dd of=/dev/sdc1`

準備好驅動的usb後即可開始安裝

## 安裝步驟

1. Download CentOS Image and write it on a USB;
2. Download HP Proliant Service Pack and locate the hpds driver inside it (於上方下載)
3. Use dd to write the appropriate driver (u0 or u1) on a separate USB drive;
4. Insert the CentOS USB in the server, boot from it but at the install menu, **press e** in case of an UEFI - system and add on the linuxefi line the following `inst.dd modprobe.blacklist=ahci`
5. **Press Ctrl+x** or the keys needed to continue the installation;
6. Insert the usb drive with the driver;
7. **Press r** to refresh the drive list and choose the appropriate drive;
8. After it unpacks, continue with the installation as usual;

<img desc="" src="//imagehosting.rickyfun.net/201609/A04-02.jpg">

<img desc="" src="//imagehosting.rickyfun.net/201609/A04-03.jpg">

<img desc="" src="//imagehosting.rickyfun.net/201609/A04-04.jpg">


### 參考資料

http://serverfault.com/questions/721523/install-centos-7-on-hp-dl120-gen9-server-with-b140i-raid-controller

http://h20564.www2.hpe.com/hpsc/swd/public/detail?sp4ts.oid=7481828&swItemId=MTX_7d939b04d27b4a56ac67627d35&swEnvOid=4176#tab3