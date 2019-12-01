---
title: 'GitLab 7.14升級8.X'
date: 2016-12-08T13:22:01+08:00
draft: false
tags: ["gitlab"]
---
## 簡介
上次安裝Gitlab大約將近一年前了，Gitlab也更新了很多功能，因此來著手進行一次升級，順便練習一下
recovery，以免意外發生時手忙腳亂．

目前版本：gitlab-ce-7.14.3-ce.1.el7.x86_64
預計更新版本：就更新到最新版吧目前是8.14.4

一開始傻傻的，想要把舊版本的backup檔，直接到8.X版本進行匯入，
很快的它就會告訴你版本不合了，
只好再用別的方式

後來我準備了兩台伺服器，
一台先安裝7.14.3
一台安裝最新版8.14.4

預計先將7.14.3的備份檔匯入第一台伺服器，之後進行升級，
然後因為個人有點龜毛，再用升級好機器備份出8.14.4版的備份檔，
來到全新的新版機器(8.14.4)再進行匯入

## 流程

### 舊機器 7.14.3 備份

#### 1. 備份backup檔
在原本的機器上下指令備份gitlab資料
  
`# gitlab-rake gitlab:backup:create`

### 新機器版本 7.14.3

這台機器要先裝好 7.14.3，匯入備份檔，再用 yum 更新到 8.14.4。

#### 1.安裝
我自己都用Omnibus
所以就先把Omnibus(gitlab-ce-7.14.3-ce.1.el7.x86_64)裝起來吧
  
[gitlab 官網有美美的教學，自己來吧](https://about.gitlab.com/downloads/#centos7)
  
其中有遇到一個問題是gitlab-ctl reconfigure時會停在[supervise_redis_sleep]
  
<img desc="" src="https:////fblog.ooopiz.com/images/201609/M12-A01-02.jpg">
  
`# sudo /opt/gitlab/embedded/bin/runsvdir-start &`
  
`# sudo gitlab-ctl reconfigure`
  
Ref:
  
- [Freeze on ruby_block[supervise_redis_sleep] action run](https://gitlab.com/gitlab-org/omnibus-gitlab/issues/430)


#### 2. 匯入backup檔

我將backup檔copy到新伺服器的備份目錄下，執行recovery時，程序會自動將檔案recovery回去
  
mv to `/var/opt/gitlab/backups/`

#### 3.開始前先停止相關數據服務連線

`# gitlab-ctl stop unicorn`
  
`# gitlab-ctl stop sidekiq`

#### 4.從1393513186編號備份中復原(看你的檔案編號是啥鬼)

`# gitlab-rake gitlab:backup:restore BACKUP=1393513186`

#### 5.啟動Gitlab

`# gitlab-ctl start`

#### 6.執行檢查

`# gitlab-rake gitlab:check SANITIZE=true`
  
檢查時有出現一些問題
  
<img desc="" src="https://fblog.ooopiz.com/images/201609/M12-A01-01.jpg">
  
解
  
`# gitlab-rake gitlab:satellites:create RAILS_ENV=production`
  
再檢查一次
  
`# gitlab-rake gitlab:check SANITIZE=true`

#### 7.版本升級

這邊是我的操作流程，有試過直接yum install gitlab-ce會有一點問題，
所以我前面加了一步gitlab-ctl upgrade很像就比較正常了
  
`# gitlab-ctl upgrade`
  
`# yum install gitlab-ce`
  
`# gitlab-ctl reconfigure`
  
`# gitlab-ctl restart`

#### 8.匯出新版本(8.14.4)backup檔

`# gitlab-rake gitlab:backup:create`

### 新機器8.14.4

`# gitlab-ctl stop unicorn`
  
`# gitlab-ctl stop sidekiq`
  
`# gitlab-rake gitlab:backup:restore BACKUP=14XXXXXXX`
  
`# gitlab-ctl start`
  
`# gitlab-rake gitlab:check SANITIZE=true`

## 注意事項

為了避免更換伺服器與重新匯入備份檔時known_host失效
  
1. 更換伺服器必須將舊伺服器/etc/ssh/ssh_host_*複製到新伺服器
2. 匯入備份檔時rebuild keys file必須選yes

<img desc="" src="//fblog.ooopiz.com/images/201609/M12-A01-03.jpg">

## 完成

<img desc="" src="https://fblog.ooopiz.com/images/201609/M12-A01-04.jpg">
