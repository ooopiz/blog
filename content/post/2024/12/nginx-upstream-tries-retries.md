---
title: "Nginx Upstream 嘗試請求，重試請求"
date: 2024-12-11T14:22:51+08:00
draft: false
tags: ["nginx"]
---

```
http {
  upstream  ups {
      server 192.168.1.1   max_fails=1  fail_timeout=10s;
      server 192.168.1.2   max_fails=1  fail_timeout=10s;
      server 192.168.1.3   max_fails=1  fail_timeout=10s;
      keepalive 1000;
  }

  server {
    listen       80;
    server_name  _;

    location / {
        proxy_next_upstream error timeout;
        proxy_next_upstream_tries 0;
        proxy_pass http://ups; 
    }
  }
}
```

## 配置說明

### max_fails=1 fail_timeout=10s
每 10 秒計數到一次失敗，節點判定為壞點 10秒鐘

以此類推

當 max_fails=0 時，停用失敗計數器，即永遠不會判定壞點

### proxy_next_upstream error timeout
那些請求狀態會被判定失敗，計算到 max_fails 的計數器

可選的項目有：
* error
* timeout
* invalid_header
* http_500
* http_502
* http_503
* http_504
* http_403
* http_404
* http_429
* non_idempotent
* off

### proxy_next_upstream_tries 0
upstream servers 嘗試請求的次數
* 0: 不限次數嘗試可用節點
* 1: 僅嘗試一次，即不會有重試的狀況，成功即成功、失敗即失敗
* 2: 第一次節點失敗後，嘗試下一個節點
* 3: 以此類推 ...


# Reference
* [Nginx 反向代理 Upstream 失败重试和封禁机制](https://www.rectcircle.cn/posts/nginx-upstream-failed-retry-ban/)
