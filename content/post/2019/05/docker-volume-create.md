---
title: '關於 Docker volume create'
date: 2019-05-10T07:22:01+08:00
draft: false
---

## 前言

某次我在看某個服務的安裝文件時，發現了 docker volume create 這個指令。  
原本我都是使用 -v 對應到我 host 機器的目錄  
ex :  

`-v $(pwd)/nginx-cache:/var/cache/nginx`

後來很好奇 docker volume create 的用途還有存放路徑。  
於是就小小的研究了一下。  

## docker volume create
一般的 Linux 在執行 docker volume create … 之後，  
可以在 /var/lib/docker/volumes 看到 docker 幫你建立 volume 名稱的資料夾。  

![docker volume ls](https://fblog.loopbai.com/images/2019/05/a001.jpg "docker volume ls")

## docker volume create In Mac
可是當你使用 Mac 執行過 docker volume create … 之後，  
並無法在 Mac 電腦中找到 /var/lib/docker/volumes 這個目錄。  

在 Mac 電腦 是無法直接訪問 /var/lib/docker/volumes 這個目錄，  
必須先 screen 到 docker 目錄下的 tty，  
進到 tty 之後就可以在 /var/lib/docker/volums 看到 create 的目錄名稱了。  

`$ screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty`

![docker volume store](https://fblog.loopbai.com/images/2019/05/a002.jpg "docker volume store")


## 你可能會遇到的問題
### 一、你可能會遇到你連入 tty 之後裡面都是亂碼

如果有發生顯示混亂的問題，有可能是你 screen 連進 tty ，  
接著使用 `ctrl` `a` + `d` detach screen ，又 screen tty 一次，就會產生畫面混亂。  

正確的做法是：  

- 使用 `ctrl` `a` + `d` detach screen，就用 screen -r 來重新連結 screen
- 或者用 `ctrl` `a` + `k` 來結束這個 screen

---
#### Reference.
- [Getting path and accessing persistent volumes in Docker for Mac](https://timonweb.com/posts/getting-path-and-accessing-persistent-volumes-in-docker-for-mac/)
- [since if you simply attach screen again, the terminal text will be garbleda](https://stackoverflow.com/questions/38532483/where-is-var-lib-docker-on-mac-os-x/55312677#55312677)
