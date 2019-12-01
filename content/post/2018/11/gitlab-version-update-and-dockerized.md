---
title: "Gitlab-ce 版本升級與容器化"
date: 2018-11-01T10:45:51+08:00
draft: false
tags: ["gitlab"]
---
## 升級目標
* gitlab-ce:8.14.4 升級到 gitlab-ce:11.3.4
* Omnibus 轉移到 Docker 容器（Dockerized）

## 步驟流程
-  一、備份 Omnibus 上的資料
-  二、準備 docker 環境
-  三、啟動新環境（使用 gitlab-ce:8.14.4-ce.0 版本的 Image）與還原
-  四、版本逐步升級

## 一、備份 Omnibus 上的資料

`$ gitlab-rake gitlab:backup:create`


## 二、準備 docker 環境
### Install docker, docker-compose
### 檔案存放的根目錄我設定在 /srv/gitlab，因此先在母體主機建立三個資料夾後續給 docker 掛載。
* /srv/gitlab/config
* /srv/gitlab/logs
* /srv/gitlab/data

## 三、啟動新環境（使用 gitlab-ce:8.14.4-ce.0 版本的 Image）與匯入

### 複製 omnibus 機器下的主機金鑰組到新環境
- From omnibus (/etc/ssh/ssh_host\_*) copy to /srv/gitlab/config/

### 撰寫 docker-compose.yaml 如下
- hostname 與 external_url 替換成自己的參數

```
web:
  image: 'gitlab/gitlab-ce:8.14.4-ce.0'
  container_name: gitlab
  restart: always
  hostname: 'git.example.com'
  environment:
    TZ: Asia/Taipei
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://git.example.com'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '22:22'
    - '80:80'
    - '443:443'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'

```

### 使用上方的docker-compose 啟動 gitlab-ce
`$ docker-compose up -d`

`$ docker-compose logs -f`

### 還原備份檔
#### a. 將檔案放置到/srv/gitlab/data/backups/1538935763_gitlab_backup.tar

#### b. 連線至container
`$ docker exec -it gitlab /bin/bash`

#### c. 停止相關數據服務連線
`$ gitlab-ctl stop unicorn`

`$ gitlab-ctl stop sidekiq`

#### d. 從1393513186編號備份中復原
`$ gitlab-rake gitlab:backup:restore BACKUP=1539079268`

#### e. 啟動 Gitlab
`$ gitlab-ctl start`

#### f. 檢查
`$ gitlab-rake gitlab:check SANITIZE=true`

![gitlab check](https://fblog.ooopiz.com/images/2018/11/a001.png "gitlab check")

#### g. 修正錯誤 Uploads directory setup correctly? ... no
`$ find /var/opt/gitlab/gitlab-rails/uploads -type d -not -path /var/opt/gitlab/gitlab-rails/uploads -exec chmod 0700 {} \;`

#### h. 再檢查
`$ gitlab-rake gitlab:check SANITIZE=true`

#### i. 升級postgress (版本 8 升級到版本 9 必須升級 postgress 詳見官網)
`$ gitlab-ctl pg-upgrade`

#### j. 再檢查
`$ gitlab-rake gitlab:check SANITIZE=true`

#### k. 啟動
`$ gitlab-ctl restart`

![gitlab-ce:8.14.4](https://fblog.ooopiz.com/images/2018/11/a002.png "gitlab-ce:8.14.4")


## 【四、版本逐步升級】
### 升級流程
* Update to gitlab-ce:9.2.10-ce.0
* Update to gitlab-ce:10.8.7-ce.0
* Update to gitlab-ce:11.3.4-ce.0

升級時希望產生包含最新參數的 gitlab.rb 設定檔，因此每次升級前我都會先刪除 gitlab.rb。

升級過程逐步調整 docker-compose.yaml 的 image 版本，每一個大版號逐步升級。

* 1. 刪除 gitlab.rb
* 2. 停止並刪除 Container
  * $ docker-compose down
* 3. 修改 docker-compose.yaml 的 image 版本
* 4. 啟動 Container
  * $ docker-compose up -d
  * 觀察log $ docker-compose logs -f
* 5. 執行 gitlab 的檢查程序
  * $ docker exec -gitlab gitlab-rake gitlab:check SANITIZE=true

```
web:
#  image: 'gitlab/gitlab-ce:8.14.4-ce.0'
#  image: 'gitlab/gitlab-ce:9.2.10-ce.0'
#  image: 'gitlab/gitlab-ce:10.8.7-ce.0'
  image: 'gitlab/gitlab-ce:11.3.4-ce.0'
  container_name: gitlab
  restart: always
  hostname: 'git.example.com'
  environment:
    TZ: Asia/Taipei
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://git.example.com'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '22:22'
    - '80:80'
    - '443:443'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'

```

### gitlab-ce:9.2.10-ce.0
![gitlab-ce:9.2.10](https://fblog.ooopiz.com/images/2018/11/a003.png "gitlab-ce:9.2.10")

### gitlab-ce:10.8.7-ce.0
![gitlab-ce:10.8.7](https://fblog.ooopiz.com/images/2018/11/a004.png "gitlab-ce:10.8.7")

### gitlab-ce:11.3.4-ce.0
![gitlab-ce:11.3.4](https://fblog.ooopiz.com/images/2018/11/a005.png "gitlab-ce:11.3.4")


### 升級完成後，在統一調整 gitlab.rb 的參數
```
$ vi gitlab.rb

//=========
external_url 'http://git.example.com’
gitlab_rails['gitlab_email_from'] = 'gitlab@example.com'
gitlab_rails['gitlab_email_display_name'] = 'GitLab'

...

```
