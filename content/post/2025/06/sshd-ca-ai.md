---
title: "SSH CA Auth"
date: 2025-06-26T10:32:51+08:00
draft: false
tags: ["ssh"]
---

# 告別密碼！使用 SSH CA 證書實現更安全、更方便的伺服器登入

您是否還在為管理多台伺服器上數不清的 `authorized_keys` 檔案而煩惱？或是擔心某位同仁的私鑰外洩，卻無法輕易地撤銷其存取權限？

傳統的 SSH 公鑰認證雖然比密碼安全，但在大規模的環境中，金鑰管理本身就是一個挑戰。今天，我們要介紹一個更優雅、更安全的解決方案：**SSH 憑證頒發機構 (Certificate Authority, CA)**。

透過建立自己的 CA，您可以集中管理所有伺服器的信任關係。伺服器不再需要知道每一個使用者的公鑰，它只需要信任您的 CA。接著，您可以為每一位使用者簽發有時效性的短期證書，大幅提升安全性與管理便利性。

這篇文章將帶您一步步建立自己的 SSH CA，並使用它來簽發使用者證書，實現無痛、安全的伺服器登入。

## 核心概念與角色分工

在開始之前，讓我們先理解整個流程中的三個主要角色以及它們各自掌管的檔案。

| 角色 | 職責 | 相關檔案 |
| :--- | :--- | :--- |
| **憑證頒發機構 (CA)** | 簽署使用者公鑰，核發證書。是信任的根源。 | `ca_key` (私鑰), `ca_key.pub` (公鑰) |
| **SSH 伺服器 (Server)** | 被登入的遠端主機。它不認識使用者，只信任 CA。 | `ca_key.pub` (CA 的公鑰) |
| **SSH 客戶端 (Client)** | 發起連線的使用者。持有自己的私鑰和 CA 核發的證書。| `id_ed25519` (私鑰), `id_ed25519-cert.pub` (證書) |

簡單來說，**Server** 藉由擁有 **CA 的公鑰**來信任 **CA**。**Client** 藉由持有 **CA 簽發的證書**來向 **Server** 證明自己的身份。

---

## Step 1: 建立憑證頒發機構 (CA)

**位置：** 在您的管理工作站或一個安全的機器上 (此處即為 CA)。

首先，我們需要產生一組專門用來當作 CA 的金鑰。這組金鑰是整個信任鏈的核心，請務必妥善保管 CA 的私鑰 (`ca_key`)。

```bash
ssh-keygen -t rsa -b 4096 -f ca_key -C "My SSH Certificate Authority"
```

*   `-t rsa -b 4096`: 使用 4096 位元的 RSA 演算法，提供強大的加密保護。
*   `-f ca_key`: 指定金鑰檔案的名稱為 `ca_key`。
*   `-C "My SSH Certificate Authority"`: 為金鑰加上註解，方便識別。

執行後，您會得到兩個檔案，這兩個檔案都**存放在 CA 這台機器上**：
*   `ca_key`: CA 的私鑰 (請務必保密！)
*   `ca_key.pub`: CA 的公鑰 (稍後需要將它分發到所有您要管理的伺服器上)

## Step 2: 設定 SSH 伺服器信任 CA

**位置：** 在您想管理的每一台 **SSH 伺服器 (Server)** 上。

接下來，我們要讓目標伺服器上的 SSH 服務 (sshd) 信任我們剛剛建立的 CA。

首先，將 CA 的公鑰 `ca_key.pub` 安全地複製到您的伺服器上，並放置在一個固定的位置，例如 `/etc/ssh/ca_key.pub`。

然後，修改伺服器上的 SSH 設定檔 `/etc/ssh/sshd_config`，加入以下這一行：

```ini
TrustedUserCAKeys /etc/ssh/ca_key.pub
```

這行設定告訴 sshd：「任何由 `/etc/ssh/ca_key.pub` 這個 CA 公鑰對應的私鑰所簽發的證書，都是可信的。」

修改完設定後，記得重新啟動 sshd 服務讓設定生效：

```bash
sudo systemctl restart sshd
```

## Step 3: 為使用者產生客戶端金鑰

**位置：** 在 **SSH 客戶端 (Client)** 的機器上，通常是使用者的個人電腦。

現在，讓需要登入伺服器的使用者產生自己的 SSH 金鑰。這跟傳統的作法完全一樣。

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "user@example.com"
```

*   `-t ed25519`: 使用 Ed25519 演算法，它比 RSA 更快且同樣安全。
*   `-f ~/.ssh/id_ed25519`: 指定金鑰檔案的路徑與名稱。
*   `-C "user@example.com"`: 使用者的 email 作為註解。

使用者會得到兩個檔案，這兩個檔案都**存放在 Client 的 `~/.ssh` 目錄下**：
*   `id_ed25519`: 使用者的私鑰 (使用者自己保管)
*   `id_ed25519.pub`: 使用者的公鑰 (這個檔案需要交給 CA 來簽署)

## Step 4: 簽發使用者證書

**位置：** 回到 **CA** 機器上操作。

這是最關鍵的一步。CA 管理員需要取得**使用者**的公鑰 `id_ed25519.pub`，然後使用 CA 的私鑰 (`ca_key`) 來簽署它，產生一份有時效性的證書。

```bash
ssh-keygen -s ca_key -I "user@example.com-cert" -n user1,user2 -V +52w id_ed25519.pub
```

讓我們來分解這個指令：
*   `-s ca_key`: 指定用來簽署的 CA **私鑰**。
*   `-I "user@example.com-cert"`: 為這個證書設定一個唯一的識別碼 (Identifier)，這個 ID 會出現在伺服器的登入日誌中，方便追蹤。
*   `-n user1,user2`: 指定此證書允許登入的**伺服器使用者名稱**。這是一個強大的功能，您可以限制這把鑰匙只能用 `user1` 或 `user2` 的身份登入。
*   `-V +52w`: 設定證書的有效期。`+52w` 代表 52 週。
*   `id_ed25519.pub`: 要被簽署的使用者公鑰。

執行成功後，會在 CA 機器上產生一個新的檔案：
*   `id_ed25519-cert.pub`: 這就是簽發好的**使用者證書**！

最後，CA 管理員需要將這份證書檔 `id_ed25519-cert.pub` 安全地回傳給使用者。

## Step 5: 使用證書登入

**位置：** 回到 **SSH 客戶端 (Client)** 的機器上。

使用者收到 CA 核發的證書 `id_ed25519-cert.pub` 後，需要將它和自己的私鑰放在同一個目錄下。

現在，使用者的 `~/.ssh` 目錄下應該有這兩個檔案：
1.  `id_ed25519` (他自己的私鑰)
2.  `id_ed25519-cert.pub` (CA 核發的證書)

就這樣！使用者現在可以直接登入，不再需要 `authorized_keys` 檔案。

```bash
ssh user1@your_server_ip
```

**認證流程拆解：**
1.  Client 使用 `id_ed25519` 私鑰和 `id_ed25519-cert.pub` 證書向 Server 發起連線。
2.  Server 收到連線請求，看到證書。
3.  Server 使用設定好的 `TrustedUserCAKeys` (`/etc/ssh/ca_key.pub`) 來驗證證書的簽名是否為真。
4.  驗證成功，且證書未過期、登入使用者名稱 (`user1`) 也符合規定，允許登入。

## 實用工具：查看證書內容

如果您想確認證書的詳細資訊，例如有效期、允許登入的使用者等，可以使用以下指令：

```bash
ssh-keygen -L -f id_ed25519-cert.pub
```

輸出結果會像這樣：

```
id_ed25519-cert.pub:
        Type: ssh-ed25519-cert-v01@openssh.com user certificate
        Public key: ED25519-CERT SHA256:abvpqWrGyRo6Ubb9u6CFgPldA1O/E8rhws8kmGbFlMc
        Signing CA: RSA SHA256:pzWbZ7jVW8qVYIBbKpRSu1latMeZ/HDs5QkzJ6dFu0I (using rsa-sha2-512)
        Key ID: "user@example.com-cert"
        Serial: 0
        Valid: from 2025-06-09T06:30:00 to 2025-06-09T06:34:53
        Principals:
                user1
                user2
        Critical Options: (none)
        Extensions:
                permit-X11-forwarding
                permit-agent-forwarding
                permit-port-forwarding
                permit-pty
                permit-user-rc
```

您可以清楚地看到簽署的 CA、有效期 (`Valid`)、以及允許登入的使用者 (`Principals`)。

## 總結

使用 SSH CA 證書管理伺服器存取權限，帶來了許多好處：

*   **集中管理:** 只需要在伺服器上設定一次 `TrustedUserCAKeys`，之後所有的人員變動都只需要在 CA 端操作。
*   **金鑰輪換與撤銷:** 不再需要登入每台機器去移除 `authorized_keys`。只要簽發短期證書，證書過期後存取權限自動失效。
*   **提升安全性:** 短期證書大幅縮小了金鑰外洩的風險時間窗。
*   **稽核與追蹤:** 透過證書的 Key ID，可以清楚地在伺服器日誌中追蹤誰在何時進行了操作。

雖然一開始的設定比單純的公鑰認證多幾個步驟，但從長遠來看，SSH CA 為您省下的管理時間與帶來的安全性提升，絕對是值得的投資。現在就動手試試看吧！
