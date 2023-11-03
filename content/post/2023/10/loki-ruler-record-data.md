---
title: "Loki 使用 Ruler's Record Data 處理大量日誌統計"
date: 2023-10-31T17:37:01+08:00
draft: false
tags: ["loki"]
---

## Loki 環境說明

1. Loki 版本 2.9.2
2. Loki 使用 3台 Monolithic mode 的 cluster
3. ring kvstore 使用 memberlist
4. Storage 在 AWS S3

## 情境說明

目前使用 Loki 記錄 nginx 的訪問日誌，
日誌有點份量之後，Loki 原生的統計函數變得相當吃緊，查詢請求動不動就跑到 CPU 100% 然後 timeout。

嘗試過將機器規格提升到兩台 32 core 的機器，雖然可以感覺到查詢速度有變快，但效果還是非常不理想。
沒人查詢時基本上 CPU 也是整個空閒，相當的浪費資源。

官方文件上有看到 record data 的做法。
基本上是利用 ruler 模組，定期執行統計，記錄到 prometheus 或其它支援的 storage，不用每次都跑一堆計算，可以改拉 prometheus 預算好的資料。

下圖取自 record data 後拉取的資料 (24小時有 272M筆訪問記錄，284GB)

![dashboard](https://fblog.ooopiz.com/images/2023/10/a001.png)

## Ruler

單機的 Loki 你可以將 rule 規則存放在 Disk 中，直接編輯，  
如果是 cluster 可以啟用 rule api 來管理規則，將規則存放到類似 S3 的 storage 供每個節點存取。  
(下述的範例以 cluster 為原則)

### Loki 設定範例

啟用 ruler 設定資料寫入 prometheus server

```yaml
common:
  ring:
    kvstore:
      store: memberlist

memberlist:
  bind_port: 7946
  join_members:
    - 172.31.37.120:7946
    - 172.31.30.184:7946
    - 172.31.29.89:7946

ruler:
  enable_api: true
  enable_sharding: true
  storage:
    type: s3
    s3:
      s3: s3://<access_key>:<uri-encoded-secret-access-key>@<region>
      bucketnames: <bucket1,bucket2>
  remote_write:
    enabled: true
    client:
      url: http://prometheus_server:9090/api/v1/write
```

設定重點:

1. 啟用 enable_api (單機可忽略, 可以存在disk, 直接編輯)
2. 啟用 enable_sharding (單機可忽略)
3. 設定 遠端 storage 空間存 ruler 規則 (單機可忽略)
4. 設定 ring kvstore 集群溝通 (單機可忽略)
5. 啟用 remote_write 並指定你要寫入的地方

設定完成後你要能 GET /ruler/ring 看到狀態 (cluster)

![loki ruler ring](https://fblog.ooopiz.com/images/2023/10/a003.png)

### Ruler Api

可用的 Ruler Api

Endpoint: http://lokiserver:3100

* `GET /ruler/ring`
* `GET /loki/api/v1/rules`
* `GET /loki/api/v1/rules/{namespace}`
* `GET /loki/api/v1/rules/{namespace}/{groupName}`
* `POST /loki/api/v1/rules/{namespace}`
* `DELETE /loki/api/v1/rules/{namespace}/{groupName}`
* `DELETE /loki/api/v1/rules/{namespace}`

### 設定規則

設定 namespace: nginx, groupName: RulesA 的規則

```
curl --location 'http://localhost:3100/loki/api/v1/rules/nginx' \
--header 'Content-Type: application/yaml' \
--data '
name: RulesA
interval: 1m
rules:
  - record: nginx:requests:counter1m
    expr: |
      sum by (instance) (count_over_time({app="nginx"} [1m]))
  - record: nginx:requests:bytes1m
    expr: |
      sum by (instance) (bytes_over_time({app="nginx"} [1m]))
'
```

設定 namespace: nginx, groupName: RulesB 的規則
```
curl --location 'http://localhost:3100/loki/api/v1/rules/nginx' \
--header 'Content-Type: application/yaml' \
--data '
name: RulesB
interval: 1m
rules:
  - record: nginx:requests:bodybytessent1m
    expr: |
      sum by (instance) (sum_over_time({app="nginx"} | json | unwrap body_bytes_sent [1m]))
'
```

1. /loki/api/v1/rules/nginx 的 nginx 就是 namespace
2. RulesA, RulesB 是 groupName
3. 同個 namespace 下可以有多個 groupName
4. 同個 groupName 下可以有多個 rule
5. 刪除或修改的最小單位是 groupName
6. 會根據你的查詢寫入 labels
   * 上面的例子: 寫入 prometheus 的 label 會對應到你 sum 的欄位
   * 你需要根據你 Loki 的 label 跟你要怎麼查詢，去規劃你的 logQL
7. 可以額外定義 labels
   ```
   rules:
     - record: nginx:requests:counter1m
       expr: sum(rate({container="nginx"}[1m]))
       labels:
         cluster: "us-central1"
   ```

### 查詢規則

當你設定完成，呼叫查詢 api 即可得到你剛設定的規則了。

`curl localhost:3100/loki/api/v1/rules`

```
nginx:
    - name: RulesA
      interval: 1m
      rules:
        - record: nginx:requests:counter1m
          expr: |
            sum by (instance) (count_over_time({app="nginx"} [1m]))
        - record: nginx:requests:bytes1m
          expr: |
            sum by (instance) (bytes_over_time({app="nginx"} [1m]))
    - name: RulesB
      interval: 1m
      rules:
        - record: nginx:requests:bodybytessent1m
          expr: |
            sum by (instance) (sum_over_time({app="nginx"} | json | unwrap body_bytes_sent [1m]))
```

## 總結

個人也用 PLG (promtial, Loki, Grafana) 一段時間了。  
來分享一些我對 Loki 的想法：

### 選用 Loki 的原因
1. Grafana 生態系，可以很好的跟 Grafana 融合
2. 覺得 ELK 太笨重，試試新的方案

### 實際使用

Loki 部署時直接啟動 binary 檔即可，對比 elasticsearch 簡單許多。  
但 Loki 繁雜的設定檔配置起來卻不怎麼輕鬆。  
一個 binary 全部運行的模組都包在裡面，  

每個模組都有其可以設定的參數，參數名稱時常有所重疊，  
加上文檔看起來不太直覺，個人花了不小的一段時間才比較理解參數的佈局與意義。

Loki 本身概念跟 Elasticsearch 有些不同，  
收集 Log 時，Loki 以 label 為單位分成 stream 壓縮存放。  
沒有其它額外的處理，  
好處是寫入效能相當優異，你應該可以用較普通的機器規格收納極大量的記錄。  

在日誌查詢的部分，如有明確的查詢字段，在查詢的效能上我覺得也很不錯。

至於聚合的部分，效果可能就不怎麼好，  

例如： 
* count_over_time
* bytes_over_time
* sum_over_time

以我上方提到的日誌量來說，使用這些聚合的操作都會耗費大量的 CPU，
即便只有 1 或 3 小時。  
更遑論有些是 unwrap 提取出來運算的值，  

通過加大 memory cache，加大機器規格，想要有更好的效能來快速呈現 dashboard，現實是幾個小時的資料都跑不出來。

最後藉由 record data 每隔一段時間將資料計算好寫入 prometheus  
來解決這個困境。  
平常花費一些 CPU 資源來運算，需要報表時即可快速呈現，也算有了個滿意的解法來解決問題。

總體來說 Loki 應該還算相對年輕的日誌整合方案，期待它後續的發展。
