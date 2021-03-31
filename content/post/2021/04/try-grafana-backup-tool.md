---
title: "Grafana 備份工具 - grafana-backup-tool"
date: 2021-04-01T01:02:25+08:00
draft: true
tags: ["grafana"]
---

## 説明

最近剛好要做 Grafana 的資料遷移，  
理論上遷移時將 grafana 的 sqlite 一起搬過去應該是沒問題，  
但牽涉到版本升級，有點不確定性。  
剛好看到一個不錯的工具 grafana-backup-tool，是透過 api 的方式進行備份還原，  
正好試用看看，平常備份也可以使用。  

## 情境

* Grafana 資料遷移 - 域名為假設域名
  * 原站 - http://grafana.example.com (version: 6.4.3)
  * 新站 - http://new.grafana.example.com (version: 7.3.4)

## 步驟

### 一. 安裝 grafana-backup-tool

隨便找一台可以訪問到 Grafana site 的 Linux

`pip install grafana-backup`

### 二. 建立 API Token

在要備份 與 要還原的 Grafana 都建立 API KEY

![api key](https://fblog.ooopiz.com/images/2021/03/b001.jpg)
![api key](https://fblog.ooopiz.com/images/2021/03/b002.jpg)

### 三. 設定檔

建立備份目標的設定檔 grafana.json (token 填入上方所建立的)

```
{
  "grafana": {
    "url": "http://grafana.example.com",
    "token": "{YOUR_GRAFANA_TOKEN}",
  }
}
```

建立還原目標的設定檔 grafana-new.json (token 填入上方所建立的)

```
{
  "grafana": {
    "url": "http://new.grafana.example.com",
    "token": "{YOUR_GRAFANA_TOKEN}",
  }
}
```

### 四. 備份 from grafana.example.com

`grafana-backup save --config=grafana.json`

![grafana backup](https://fblog.ooopiz.com/images/2021/03/b003.jpg)

備份檔路徑

![output](https://fblog.ooopiz.com/images/2021/03/b004.jpg)

* 備份的内容可包含

  * folders
  * dashboards
  * datasources
  * alert-channels
  * organizations (需設定 GRAFANA_ADMIN_ACCOUNT and GRAFANA_ADMIN_PASSWORD )
  * users (需設定 GRAFANA_ADMIN_ACCOUNT and GRAFANA_ADMIN_PASSWORD )

Example:

```
{
    "grafana": {
        ...

        "admin_account": "admin",
        "admin_password": "admin"
    }
}
```

### 五. 還原 to new.grafana.example.com

* 全部還原

  * `grafana-backup save --config=grafana-new.json _OUTPUT_/202103310331.tar.gz`

* 逐項還原

  * `grafana-backup restore --config=grafana-new.json _OUTPUT_/202103310331.tar.gz --components=datasources`
  * `grafana-backup restore --config=grafana-new.json _OUTPUT_/202103310331.tar.gz --components=folders,dashboards`
  * `grafana-backup restore --config=grafana-new.json _OUTPUT_/202103310331.tar.gz --components=alert-channels`

## Reference

* https://github.com/ysde/grafana-backup-tool