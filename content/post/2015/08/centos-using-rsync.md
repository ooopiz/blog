---
title: 'CentOS 使用rsync'
date: 2015-08-31T13:06:01+08:00
draft: false
tags: ["centos"]
---

## 簡介
rsync 是一種遠端複製的技術，透過 rsync 可以輕鬆的將機器上的檔案做鏡像備援到其他機器．

首先先查詢一下，機器是否已經安裝．

`rpm -qa | grep rsync`

如果沒有的話就 yum 一下吧

***做 rsync 的時候 server 端與 client 端都必須要安裝***

`yum install rsync`


## 指令

rsync的指令非常的簡單

* 這個指令不會刪除目的端多餘的檔案
  * `rsync -avz /opt/data root@192.168.1.245:/opt/data-backup`
  * `rsync -avz root@192.168.1.245:/opt/data-backup /opt/data`

* 這個指令則會完全的鏡像，如果目的端有來源端沒有的檔案，該檔案會被刪除
  * `rsync -avz --delete /opt/data root@192.168.1.245:/opt/data-backup`
  * `rsync -avz --delete root@192.168.1.245:/opt/data-backup /opt/data`


當你做 rsync 時，必須使用到 ssh port，所以你的防火牆 22 port 必須打開，  
另外會要求你輸入密碼，  
假設你要做自動的排程，就必須使用 ssh key 來達到不用密碼可以登入．
