---
title: "你知道在 Mac 上，怎麼把資料夾的檔案轉成 ISO 檔嗎？"
date: 2020-02-13T20:20:54+08:00
draft: false
tags: ["macos"]
---

## 先聊個天

很棒，今天以前我也不知道，我找解法找了好幾天，這篇獻給有緣的地球人。

雖然我有找到別的軟體可以做這個事情，但要付錢我就沒有使用了。

我在網路上找許久，不管怎麼下關鍵字都是教怎麼把 ISO 燒進 usb

就是沒有檔案打包 ISO 檔的

終於...

## 資料夾轉成映像檔

磁碟工具程式 > 檔案 > 新增映像檔 > 來自檔案夾的映像檔 > 格式選 DVD/CD 母片

![add](https://fblog.ooopiz.com/images/2020/02/a001.jpg)

於是它把我的檔案製作成了 .cdr

## 轉檔 cdr to iso

最先我找到的指令是這一句

`$ hdiutil makehybrid -iso -joliet -o rpms.iso rpms.cdr`

![hdiutil](https://fblog.ooopiz.com/images/2020/02/a002.jpg)

成功轉檔

## 在 VirtualBox 掛載

用 virtualbox 的 VM 掛載 ISO 試試

![mount](https://fblog.ooopiz.com/images/2020/02/a003.jpg)
![mount](https://fblog.ooopiz.com/images/2020/02/a004.jpg)

掛載成功

## 燒錄在光碟的檔名變短

後來在使用 ISO 時，發現 ISO 裡有些檔案，檔案名稱自動變短，搜尋了一下才發現有格式上的問題。

在各種格式下的檔案名稱有其長度的限制

ISO 9600

* LV1：11字元，8.3格式
* LV2：31字元
* LVX：219字元

Joliet

* LV1：64個字元
* LVX：110個字元

UDF：255個字元

於是將轉檔的指令改成 -udf

`$ hdiutil makehybrid -iso -udf -o rpms.iso rpms.cdr`

## 重點

講了這麼多這裡才是重點，上面的流程我做了幾次真心覺得麻煩，想說 hdiutil 難道不能幫我直接做成 ISO 嗎？

終於終於讓我找到解法了

`$ hdiutil makehybrid -iso -udf -o rpms.iso ~/Download/rpms`

指令跟上面有 87% 像，但不知道可以這樣用，哈哈哈..

## Reference

* [檔案名稱的長度限制？](https://www.ptt.cc/bbs/CD-R/M.1251003738.A.24D.html)
* [hdiutil](https://ss64.com/osx/hdiutil.html)
* [How to Create a DVD ISO Image from Files on a Mac](https://www.provideocoalition.com/howto_create_dvd_iso_from_files_mac/)