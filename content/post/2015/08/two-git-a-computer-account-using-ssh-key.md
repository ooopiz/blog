---
title: '一台電腦兩個Git帳號使用SSH Key'
date: 2015-08-24T03:05:01+08:00
draft: false
---
#在設定檔中加入設定檔
Windows下的路徑C:\Users\Ricky\.ssh
```config config
Host ricky.org
  Hostname ricky.org
  Port 29418
  User rickyhuang
  IdentityFile C:\Users\Ricky\.ssh\id_rsa
Host peter.org
  Hostname peter.org
  Port 65095
  User peter
  IdentityFile C:\Users\Ricky\.ssh\id_rsa_second
```

#取消glogal mail,設定每個項目repo自己的 user.email
>pull的時候是識別郵箱，所以不能使用global的user.email

**取消global**
`git config --global --unset user.name`
`git config --global --unset user.email`

**設定每個項目repo自己的 user.email**
`git config  user.email "xxxx@xx.com"`
`git config  user.name "ricky"`


###Woindows下要生成key可以使用 git bash 裡面有內建的ssh command
<img src="//fblog.loopbai.com/images/201508/A02-01.png">

再輸入，即可生成ssh key
`ssh-keygen -t rsa`
