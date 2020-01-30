---
title: "Kafka 基本設定與用法"
date: 2020-01-30T22:33:26+08:00
draft: flase
tags: ["kafka", "zookeeper"]
---

## Prepare
安裝 kafka 前先在環境中安裝 Java and Scala

## Install
看官網的 quick start 吧

- Offical [Quick start](https://kafka.apache.org/quickstart)
- Offical [Download](https://kafka.apache.org/downloads)

## 設定

### 設定啟動 kafka 的用戶 與權限

`$ useradd kafka`

`$ chown -R kafka:kafka /opt/kafka*`

### 設定 systemd 的 守護進程

`$ vi /etc/systemd/system/zookeeper.service`

```
[Unit]
Description=zookeeper
After=syslog.target network.target

[Service]
Type=simple
User=kafka
Group=kafka
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh

[Install]
WantedBy=multi-user.target

```

`$ vi /etc/systemd/system/kafka.service`

```
[Unit]
Description=Apache Kafka
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
Group=kafkaa
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target

```

### kafka 設定
先設定一個主機名稱給hosts

![](https://fblog.ooopiz.com/images/2020/01/c001.png)

接著到你 kafka 安裝的目錄下 找到 config/server.properties 設定檔修改設定

![](https://fblog.ooopiz.com/images/2020/01/c002.png)

- listeners：啓動kafka服務監聽的ip和端口，這邊不需特別設定
- advertised.listeners：consumer 和 producer 連接的地址，kafka會把該地址註冊到zookeeper中，如果你沒設定要連線的 ip 或 域名，外部是連不上來的

這邊設定 kafka-server 的主機名稱，就允許了外部使用這個 hostname 連到 kafka

### 啟動
kafka 服務必須依賴 zookeeper 因此必須先啟動 zookeeper 再啟動 kafka

`systemctl enable --now zookeeper`

`systemctl enable --now kafka`

### 防火牆

要給外部使用時記得開防火牆

zookeeper service
* 2181

kafka service
* 9092

## Usage

### 名詞說明
- consumer: 消費者，你可以把他當成訂閱消息的人
- producer: 生產者，送消息給 Kafka 的角色

### /kafka-console-consumer.sh（消費者、訂閱、Consumer）
`$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic DemoTopic --from-beginning`

- --form-beginning 代表會從 topic 最早的 record 開始處理。

### /kafka-console-producer.sh（生產者、producer）
`$ /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic DemoTopic`

### dmeo
左邊是 consumer，右邊是 producer，
訂閱者先向 Kafka 訂閱 DemoTopic 這個 topic，
消息傳送者在向 kafka 傳送消息

![](https://fblog.ooopiz.com/images/2020/01/c004.gif)

## Reference
- [Install Kafka in RHEL 7](https://medium.com/@dindanovitasari/install-kafka-in-rhel-7-f15d10a07246)
- [How to install kafka on RHEL 8](https://linuxconfig.org/how-to-install-kafka-on-redhat-8)
