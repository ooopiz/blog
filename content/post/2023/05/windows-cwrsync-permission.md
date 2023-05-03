---
title: "Windows rsync (cwRsync) 權限問題"
date: 2023-05-03T11:27:28+08:00
draft: false
---

## Windows 使用 rsync 引發的權限問題

如果你在 Linux 上使用過 rsync 指令，多少需要瞭解一下檔案權限的問題。  

在 Windows 上 Rsync，可以透過一些模擬 Linux API 的指令來實現  
這裡用到的是 cwRsync，可以到官網下載 rsync client 純指令版  
(rsync-client 是 free 的，其它有些東西可能需要付費，看自己的需求)

這裡列舉幾個我自己在 Windows 上遇到的權限問題

1. rsync 後的檔案或資料夾，無法開啟或刪除檔案
2. 資料夾安全性顯示 `權限排序不正確` 跟 null sid
   * ![權限排序不正確](https://fblog.ooopiz.com/images/2023/05/a001.png)
   * ![null sid](https://fblog.ooopiz.com/images/2023/05/a002.png)

## 權限問題處理

### 1. 無法開啟或刪除資料夾

可以試著在執行 rsync 指令時加上參數 `--chmod=ugo=rwX -r` 來改變檔案的權限

`rsync -avz --chmod=ugo=rwX -r <source> <destination>`

### 2. 資料夾安全性顯示 `權限排序不正確` 跟 null sid

如果權限排序不正確，可以試著在 cwrsync/etc 底下加入 fstab 檔，  
設定 `noacl` 來排除，具體可以參考 refer 連結，範例如下:

```
# /etc/fstab

none /cygdrive cygdrive binary,noacl,posix=0,user 0 0
```

![fatab 放置路徑](https://fblog.ooopiz.com/images/2023/05/a004.png)

正確權限示意圖(沒有出現 null sid)

![正常的資料夾安全性](https://fblog.ooopiz.com/images/2023/05/a003.png)


## Reference

* [Forcing Cygwin to create sane permissions on Windows](https://blog.dhampir.no/content/forcing-cygwin-to-create-sane-permissions-on-windows)
* [Rsync on Windows: wrong permissions for created directories](https://stackoverflow.com/questions/5798807/rsync-on-windows-wrong-permissions-for-created-directories)