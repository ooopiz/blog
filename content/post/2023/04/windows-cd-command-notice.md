---
title: "Windows OS cd 指令，你應該注意的事 (device 切換)"
date: 2023-04-17T10:40:46+08:00
draft: false
tags: ["windows"]
---

## 場景

事情是這樣的，  
某天我弄了一個 windows 的 bat 檔，預計使用 rsync 將檔案同步到 windows 本地目錄。  
於是搞了個腳本，類似這樣，  
dirpath 則以環境變數的方式代入。

```bat
cd %dirpath%

rsync --delete remote local
```

想了想，  
如果前面程序如果失敗，沒有將 dirpath 建立出來，  
我這個 rsync --delete 就可怕了，於是加了一行判斷 cd 失敗就終止。

```bat
cd %dirpath%
if %ERRORLEVEL% NEQ 0 exit %ERRORLEVEL%

rsync --delete remote local
```

本機測試完後，開開心心的到其它機器去測試。  
結果開始噴 rsync delete 一些奇奇怪怪的檔案。  
我心裡想 cd 失敗的話，  
沒有 pathdir 不是應該會退出程序嗎?

細查後 dirpath 資料夾也有正常建立，  
為什麼 cd 不成功也沒有 return error code 呢?

## 實測

原因是我自己電腦上測試的時候都在 c 碟上面進行，  
當涉及 device (c, d 碟) 切換的時候， cd 指令並不會成功。  
如果路徑確實存在也不會報錯。  

後來才在 help 上找到有 device 的切換必須使用 `cd /d` 才可正常運作

![windows-cd](https://fblog.ooopiz.com/images/2023/04/a001.png)

## 結論

就是在 Windows OS 上，不管你要切到那個路徑  
都記得加上 `cd /d` 來避免這個狀況吧!

```bat
cd /d %dirpath%
if %ERRORLEVEL% NEQ 0 exit %ERRORLEVEL%

rsync --delete remote local
```
