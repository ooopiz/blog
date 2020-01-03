---
title: 'Hicloud S3雲儲存資料夾掛載'
date: 2016-08-09T02:07:01+08:00
draft: false
---
## hicloud S3雲儲存
目的：將s3的bucket掛載到Caas雲伺服器
  
主機環境：CentOS 6.4
  
說明：s3fs base on fuse所以伺服器上必須有fuse的lib
  
示意圖：

![](https://fblog.ooopiz.com/images/201608/A01-01.png)
  
Resource：

* [Hicloud S3 文檔](http://s3help.cloudbox.hinet.net/index.php/2015-02-12-07-14-27)

## s3fs-fuse 安裝

### 一、下載s3fs-fuse源碼進行安裝

 [Github s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse)

### 二、安裝所需套件

CentOS7
  
`# sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel`

CentOS6
  
`# sudo yum install automake gcc-c++ git libcurl-devel libxml2-devel make openssl-devel`
  
> fuse fuse-devel 版本必須大於 2.8.4，CentOS6 yum install只有2.8.3，所以必須手動安裝(安裝步驟於下方)，安裝完成後，重這裡接續安裝即可．

### 三、安裝步驟

`# git clone https://github.com/s3fs-fuse/s3fs-fuse.git`

`# cd s3fs-fuse`

`# ./autogen.sh`

`# ./configure -prefix=/usr`

`# make`

`# make install`

### 四、設定

要存取Hicloud的s3必須先申請一組access key與secret key
  
將key info寫入設定檔中
  
`# vi /etc/passwd-s3fs`

```
#Access Key:Secret Key 以冒號(:)區隔
#ex: 
2d69bf8ca60c2381dd1fg2as4f10s:97761d0f114562r2gfd0256436ec
```

### 五、掛載

Only ROOT
  
`# s3fs -o url=http://s3.hicloud.net.tw/,nomultipart test-123 /mnt/test-123`

All USER
  
`# s3fs -o url=http://s3.hicloud.net.tw/,nomultipart test-123 /mnt/test-123 -o allow_other`
  
<div style="color:red">注意: 下mount指令時，若出現should not have others permissions時，這時候下`chmod o-rwx /etc/passwd-s3fs`關掉其他人的權限後，在下一次mount指令就可以正常運作。</div>

## libfuse 安裝

### 一、下載源碼編譯安裝或者下載release版本安裝

[Github libfuse](https://github.com/libfuse/libfuse)
  
[Github libfuse release](https://github.com/libfuse/libfuse/releases)

### 二、安裝

> 檢查版本如果<2.8.4必須安裝至大於的版本
  
`# rpm -qa | grep fuse`
  
`# rpm -qa | grep fuse-devel`
  
`# yum remove fuse fuse-devel`
  
`# ./configure`
  
`# make -j8`
  
`# make install`

### 三、設定
安裝完成後會在/usr/local/lib產生連結，將這個路徑加入到/etc/ld.so.conf然後執行`ldconfig `刷新
  
`# export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig`

## 結語
感覺上s3fs在單一的大檔案傳輸速度還可以，零碎的檔案多的話，就不是很理想了
