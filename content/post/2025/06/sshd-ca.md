---
title: "SSHD CA AUTH"
date: 2025-06-26T10:12:51+08:00
draft: false
tags: ["ssh"]
---

## 產生一組金鑰
`ssh-keygen -t rsa -b 4096 -f ca_key -C "My SSH Certificate Authority"`

* 會產生兩個檔案
  * ca_key
  * ca_key.pub

## 公鑰分發到要被登錄的機器上 (sshd server)

`/etc/ssh/sshd_config`

```ini
TrustedUserCAKeys /etc/ssh/ca_key.pub
```

`systemctl restart sshd`

## 產生一組金鑰,做為客戶端的金鑰

`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "user@example.com"`

* 會產生兩個檔案
  * id_ed25519
  * id_ed25519.pub

## 用 ca 私鑰與 用戶公鑰簽發證書
`ssh-keygen -s ca_key -I "user@example.com-cert" -n user1,user2 -V +52w id_ed25519.pub`

* -s ca_key: 指定用於簽署的 CA 私鑰。
* -I "user@example.com-cert": 指定一個證書 ID，用於日誌記錄和審計。
* -n user1,user2: 指定此證書允許登錄的用戶名（如果未指定，則默認為金鑰的註釋部分）。這是 SSH 伺服器在驗證證書時會檢查的用戶名。
* -V +52w: 設置證書的有效期，例如這裡設置為 52 週。
  * +52w
  * +10m
* id_ed25519.pub: 要簽署的用戶公鑰文件。

* 會產生一個檔案
  *  id_ed25519-cert.pub

## 將私鑰與證書放在客戶端的 `~/.ssh` 目錄下即可登錄
`id_ed25519` to client side `~/.ssh/`
`id_ed25519-cert.pub` to client side `~/.ssh/`

## 其它
### 查看發現的證書內容
```
$ ssh-keygen -L -f id_ed25519-cert.pub

# out--------------------------------------------
id_ed25519-cert.pub:
        Type: ssh-ed25519-cert-v01@openssh.com user certificate
        Public key: ED25519-CERT SHA256:abvpqWrGyRo6Ubb9u6CFgPldA1O/E8rhws8kmGbFlMc
        Signing CA: RSA SHA256:pzWbZ7jVW8qVYIBbKpRSu1latMeZ/HDs5QkzJ6dFu0I (using rsa-sha2-512)
        Key ID: "user@example.com-cert"
        Serial: 0
        Valid: from 2025-06-09T06:30:00 to 2025-06-09T06:34:53
        Principals:
                root
        Critical Options: (none)
        Extensions:
                permit-X11-forwarding
                permit-agent-forwarding
                permit-port-forwarding
                permit-pty
                permit-user-rc
```
