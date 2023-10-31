---
title: "Loki 使用 Ruler's Record Data 處理大量日誌統計"
date: 2023-10-31T17:37:01+08:00
draft: false
tags: ["loki"]
---

## Loki 環境說明

1. Loki 使用 3台 Monolithic mode 的 cluster
2. ring kvstore 使用 memberlist
3. Storage 在 AWS S3

## 情境說明

目前使用 Loki 記錄 nginx 的訪問日誌，
日誌有點份量之後，Loki 原生的統計函數非常的吃緊，動不動就跑到 CPU 100% 然後 timeout

在官方文件上看到 record data 的做法。
基本上是利用 ruler 模組，定期執行統計，記錄到 prometheus 或其它支援的 storage，不用每次都跑一堆計算，可以改拉 prometheus 預算好的資料。

下圖取自 record data 後拉取的資料 (24小時有 272M筆記錄，284GB)

![dashboard](https://fblog.ooopiz.com/images/2023/10/a001.png)

## Ruler

如果 loki 是 cluster 必須啟用 rule api 來管理規則,不能將 ruler 存放在單台的 disk 上

### loki 設定範例

```yaml
common:
  ring:
    kvstore:
      store: memberlist

memberlist:
  bind_port: 7946
  join_members:
    - 127.0.0.1:7946
    - 127.0.0.1:17946

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

1. 啟用 enable_api (單機可忽略,可以存在disk,直接編輯)
2. 啟用 enable_sharding (單機可忽略)
3. 設定 遠端 storage 空間存 ruler 規則 (單機可忽略)
4. 設定 ring kvstore 集群溝通 (單機可忽略)
5. 啟用 remote_write

設定完成後你要能 GET /ruler/ring 看到狀態

![loki ruler ring](https://fblog.ooopiz.com/images/2023/10/a003.png)

### Ruler Api

Endpoint: http://lokiserver:3100

* GET /ruler/ring
* GET /loki/api/v1/rules
* GET /loki/api/v1/rules/{namespace}
* GET /loki/api/v1/rules/{namespace}/{groupName}
* POST /loki/api/v1/rules/{namespace}
* DELETE /loki/api/v1/rules/{namespace}/{groupName}
* DELETE /loki/api/v1/rules/{namespace}

### 設定規則

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
2. RulesA, RulesB 是 groupname
3. 同個 namespace 下可以有多個 groupName
4. 同個 groupName 下可以有多個 rule
5. 刪除或修改的最小單位是 groupName
6. 會根據你的查詢寫入 labels
7. 額外定義 labels
   ```
   rules:
     - record: nginx:requests:counter1m
       expr: sum(rate({container="nginx"}[1m]))
       labels:
         cluster: "us-central1"
   ```

### 查詢規則
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
