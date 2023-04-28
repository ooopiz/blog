---
title: 'VirtualBox Guest Addtiton安裝 for Centos'
date: 2015-09-09T09:49:01+08:00
draft: false
tags: ["virtualbox"]
---

我在 virtualbox上 面安裝的是 CentOS7 的 OS  
當你想 mount 本機的資料夾給虛擬機器使用的時候，你的 virtualbox 應該會提示你，  
你應該要安裝 **VirtualBox Guest Addtiton**

那就讓我們來開始安裝吧

## 先把 VBoxGuestAdditions.iso mount 起來

![](https://fblog.ooopiz.com/images/201509/A04-01.png "")

`mkdir /media/cdrom`

`mount /dev/cdrom /media/cdrom`

![](https://fblog.ooopiz.com/images/201509/A04-02.png "")

## 執行 VBoxLinuxAdditions.run

`sh /media/cdrom/VBoxLinuxAdditions.run`

## 接著就可以 mount 本機分享給虛擬機的資料夾了

`mkdir ~/new`

`mount -t vboxsf New ~/new`

或者你需要有特定owner的mount

`mount -t vboxsf -o uid=nginx,gid=nginx New ~/new`


## troubleshoot

在執行 VBoxLinuxAdditions.run 的時候你可能會遇到

### bzip2 command not found

![](https://fblog.ooopiz.com/images/201509/A04-03.png "")

`yum install bzip2 -y`

### Building the main Guest Additions module [失敗]

`yum install kernel-devel kernel-headers dkms gcc gcc-c++ -y`

![](https://fblog.ooopiz.com/images/201509/A04-04.png "")


解完後在執行一次

`sh /media/cdrom/VBoxLinuxAdditions.run`

![](https://fblog.ooopiz.com/images/201509/A04-05.png "")
