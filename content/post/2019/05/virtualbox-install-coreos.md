---
title: "Virtualbox 安裝 Coreos"
date: 2019-05-28T15:20:25+08:00
draft: false
tags: ["virtualbox", "coreos"]
---
## 到官網下載 coreOS ISO 檔
[Booting CoreOS Container Linux from an ISO](https://coreos.com/os/docs/latest/booting-with-iso.html)

如標題，這份 ISO 僅是開機片而已，並無安裝動作，  
如何安裝的部分下面會提到。  

## VirtualBox 新增機器
選 Linux 64 bit 即可  
![virtualbox-new-server](https://fblog.loopbai.com/images/2019/05/d001.jpg "virtualbox-new-server")

掛載剛下載的 ISO 檔  
![mount-coreos-iso](https://fblog.loopbai.com/images/2019/05/d002.jpg "mount-coreos-iso")

## 開機
官網有說明最小的 RAM 必須要 2G，一開始沒注意我也是只開了 512，下面是記憶體不足時的反應。  
  
* 512 G - <span style="color:red"> *無限重開* </span>

* 1024 G - <span style="color:red"> *boot into emergency shell* </span>
![emergency shell](https://fblog.loopbai.com/images/2019/05/d003.jpg "emergency shell")

* 2048 G - OK
![coreos boot](https://fblog.loopbai.com/images/2019/05/d004.jpg "coreos boot")

> 使用ISO開機之後，並不會把檔案裝進硬碟，在上面進行任何操作，重開機後都會消失。

## 安裝到硬碟
這個步驟要使用 coreos-install 這個指令來安裝硬碟，  
當 ISO boot 的時候，該指令就已經內建在系統裡了。  
要特別注意的是你必須寫一個 ignition.json 檔案來作為安裝時的參數，  
這個檔案可以用來設定用戶、網路、儲存、服務等。。。  
必須在設定檔中給定一個 ssh 公鑰，以利後續登入（如果有登入需求的話）  
否則裝好之後是無法使用 ssh login in 的。  

### 先查看硬碟空間在那裡
`$ sudo fdisk -l`

![fdisk -l](https://fblog.loopbai.com/images/2019/05/d005.jpg "fdisk -l")

### 編寫 ignition.json
sshAuthorizedKeys 替換成你要登入的公鑰

```
{
  "ignition": {
    "config": {},
    "timeouts": {},
    "version": "2.1.0"
  },
  "networkd": {},
  "passwd": {
    "users": [
      {
        "name": "core",
        "sshAuthorizedKeys": [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGdByTgSVHq......."
        ]
      }
    ]
  },
  "storage": {},
  "systemd": {}
}
```

### 安裝吧 coreos-install
`$ sudo coreos-install -d /dev/sda -C stable -i ~/ignition.json`

![coreos-install](https://fblog.loopbai.com/images/2019/05/d006.jpg "coreos-install")

#### coreos-install 參數說明
* -d DEVICE   Install Container Linux to the given device.
* -V VERSION  Version to install (e.g. current)
* -B BOARD    Container Linux board to use
* -C CHANNEL  Release channel to use (e.g. beta)
* -o OEM      OEM type to install (e.g. ami)
* -c CLOUD    Insert a cloud-init config to be executed on boot.
* -i IGNITION Insert an Ignition config to be executed on boot.
* -b BASEURL  URL to the image mirror (overrides BOARD)
* -k KEYFILE  Override default GPG key for verifying image signature
* -f IMAGE    Install unverified local image file to disk instead of fetching
* -n          Copy generated network units to the root partition.
* -v          Super verbose, for debugging.

### 安裝完成
安裝完成後重新開機 coreOS，就是硬碟開機了，  
並可以使用你剛剛設定的公私鑰對進行登入。  

### 其它

#### 關於 Cloud-Config，官網有提到已經不再積極開發，建議用 ignition 取代。
>  [coreos-cloudinit](https://coreos.com/os/docs/latest/cloud-config.html) is no longer under active development and has been superseded by Ignition.

#### 安裝完後可以將 memory 調低一點，不會造成無法開機，但須符合你的服務需求。

## Reference
- [noonat/coreos-virtualbox.md](https://gist.github.com/noonat/9fc170ea0c6ddea69c58)
- [Installing CoreOS Container Linux to disk](https://coreos.com/os/docs/latest/installing-to-disk.html)
- [Running CoreOS Container Linux on VirtualBox](https://coreos.com/os/docs/latest/booting-on-virtualbox.html)
- [VirtualBox中使用CoreOS的ISO镜像安装CoreOS](https://blog.51cto.com/lucien1970/1761097)