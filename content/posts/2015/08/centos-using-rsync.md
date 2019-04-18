---
layout: post
title: 'CentOS 使用rsync'
date: 2015-08-31 13:06
comments: true
categories: 
---
rsync是一種遠端備份的技術，透過rsync可以輕鬆的將機器上的檔案做鏡像備援到其他機器．

***

首先先查詢一下，機器是否已經安裝．
`# rpm -qa | grep rsync`

如果沒有的話就yum一下吧～
>做rsync的時候server端與client端都必須要安裝

`# yum install rsync`

***

rsync的指令非常的簡單
**這個指令不會刪除目的端多餘的檔案**
`# rsync -avz /opt/data root@192.168.1.245:/opt/data-backup`
or
`# rsync -avz root@192.168.1.245:/opt/data-backup /opt/data`

**這個指令則會完全的鏡像，如果目的端有來源端沒有的檔案，該檔案會被刪除**
`# rsync -avz --delete /opt/data root@192.168.1.245:/opt/data-backup`
or
`# rsync -avz --delete root@192.168.1.245:/opt/data-backup /opt/data`

***

當你做rsync時，必須使用到ssh port，所以你的防火牆22 port必須打開，
另外會要求你輸入密碼，
假設你要做自動的排程，就必須使用ssh key來達到不用密碼可以登入．

**產生金鑰**
`# ssh-keygen -t rsa`
**輸入上述指令後，下面三個問題都直接enter即可**
```config
Generating public/private rsa key pair.
Enter file in which to save the key (/home/or1/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/or1/.ssh/id_rsa.
Your public key has been saved in /home/or1/.ssh/id_rsa.pub.
```

**至此即產生完金鑰與私鑰，再透過下面的指令把私鑰上傳至欲登入的主機**
>這個動作會在你要登入的主機，產生authorized_keys

`# ssh-copy-id user@ip`
如果你的ssh port不是預設22的話
`# ssh-copy-id user@host -p 822`

**試試看是否能不輸入密碼做rsync**
`# rsync -avz --delete -e ssh /opt/data root@192.168.1.245:/opt/data-backup`
如果你的port跟人家不一樣
`# rsync -avz --delete -e "ssh -p 922" root@192.168.1.245:/opt/data-backup /opt/data`

>設定好後如果還是需要輸入密碼
>可以試著清除 .ssh 資料夾中 known_hosts 檔案上的資訊