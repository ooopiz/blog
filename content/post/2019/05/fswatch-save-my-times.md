---
title: "Fswatch Save My Times"
date: 2019-05-23T23:27:58+08:00
draft: false
---
## Fswatch 可以用來檢測資料夾與文件的變更
最近在用 vim 練習 golang，真的是 go run 到手累心也累，  
就到網路上搜看看有沒有可以監控檔案存檔事件的工具，  
於是找到了這款 Mac 可以使用的 [Fswatch](https://github.com/emcrisostomo/fswatch "Fswatch")

## 安裝
mac 上安裝就直接  
`brew install fswatch`

## 腳本
因為我只要監控 go file 有沒有異動，  
如果有的話幫我 compilar，所以腳步中有限定 .go 檔。

```
#!/bin/bash

BASEDIR=$(dirname "$0")

fswatch "$BASEDIR" | while read file
do
    filename=$(basename -- "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"

    if [ "$extension" = "go" ]
    then
        echo "=============================================\n\n"
        time go run ${file}
    fi
done
```

## Demo

![Auto compilar demo](https://fblog.loopbai.com/images/2019/05/c001.gif "Auto compilar demo")

## Reference
- [OS X使用fswatch+rsync自动检测文件夹改动并同步](https://my.oschina.net/mengshuai/blog/618354 "OS X使用fswatch+rsync自动检测文件夹改动并同步")