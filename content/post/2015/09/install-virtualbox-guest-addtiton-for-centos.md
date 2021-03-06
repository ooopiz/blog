---
title: 'VirtualBox Guest Addtiton安裝 for Centos'
date: 2015-09-09T09:49:01+08:00
draft: false
tags: ["virtualbox"]
---
>我在virtualbox上面安裝的是CentOS7的OS
>當你想mount本機的資料夾給虛擬機器使用的時候，你的virtualbox應該會提示你，
>你應該要安裝**VirtualBox Guest Addtiton**

那就讓我們來開始安裝吧

### 先把VBoxGuestAdditions.iso mount起來

![](https://fblog.ooopiz.com/images/201509/A04-01.png "")

`# mkdir /media/cdrom`

`# mount /dev/cdrom /media/cdrom`

![](https://fblog.ooopiz.com/images/201509/A04-02.png "")

### 執行VBoxLinuxAdditions.run
`# sh /media/cdrom/VBoxLinuxAdditions.run`

### 接著就可以mount本機分享給虛擬機的資料夾了
`# mkdir ~/new`

`# mount -t vboxsf New ~/new`

或者你需要有特定owner的mount

`# mount -t vboxsf -o uid=nginx,gid=nginx New ~/new`


***

#### 在執行VBoxLinuxAdditions.run的時候你可能會遇到
### <b style="color:red">bzip2 command not found</b>
![](https://fblog.ooopiz.com/images/201509/A04-03.png "")

`# yum install bzip2 -y`

### <b style="color:red">Building the main Guest Additions module [失敗]</b>
`# yum install kernel-devel kernel-headers dkms gcc gcc-c++ -y`

![](https://fblog.ooopiz.com/images/201509/A04-04.png "")


解完後在執行一次

`# sh /media/cdrom/VBoxLinuxAdditions.run`

![](https://fblog.ooopiz.com/images/201509/A04-05.png "")
