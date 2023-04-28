---
title: '2013 開放 Web 軟體安全計畫'
date: 2016-07-11T07:14:01+08:00
draft: false
---
## 2013 開放 Web 軟體安全計畫 – Open Web Application Security Project

https://www.owasp.org/index.php/Top_10_2013-Top_10

網站安全標準須防止 OWASP (開放Web軟體安全計畫 – Open Web Application Security Project)十大Web資安漏洞，其安全要求表列入下。

- A1 - Injection (注入攻擊)：
- A2 - Broken Authentication and Session Management (失效的驗證與連線管理)：
- A3 - Cross-Site Scripting(XSS) (跨站腳本程式攻擊)：
- A4 - Insecure Direct Object References (不安全的物件參考)：
- A5 - Security Misconfiguration (不當的安全組態設定)：
- A6 - Sensitive Data Exposure (敏感資料暴露)：
- A7 - Missing Function Level Access Control (缺少功能級別的存取控制)：
- A8 - Cross Site Request Forgery (CSRF) (跨站冒名請求)：
- A9 - Using Components with Known Vulnerabilities(使用已知漏洞元件)：
- A10 - Unvalidated Redirects and Forwards (未經驗證的重新導向與轉送)：

##  Top 10

### A1 - Injection (注入攻擊)：

注入攻擊可說是目前最普遍的網站應用程式的攻擊手法

#### 注入種類：

| 注入類型     | 利用介面           | 攻擊方法                 | 分隔、結尾或串接符號 |
|--------------|--------------------|--------------------------|----------------------|
| SQL 敘述注入 | SQL                | 安插SQL命令              | --'                  |
| OS 命令注入  | OS Shell           | 執行系統命令             | ；| &                |
| HTTP 注入    | HTTP               | HTTP回應標頭             | 換行符號             |
| 跨網站指令碼 | HTML               | 插入JavaScript程式碼     | < "                  |
| 郵件命令注入 | SMTP格式訊息或命令 | 注入非法的郵件標頭或本文 | 換行符號             |
| XPATH注入    | XPATH              | 注入XPATH查詢命令        | '                    |

#### 一. SQL 注入攻擊

SQL Injection攻擊的方式就很像填空題，攻擊者在網頁裡任何可以輸入資料的地方試著去猜想設計者背後的語法撰寫方式，並去猜測完整的command應該會長成怎麼樣，還有推測欄位數，table的名字，SQL的版本資訊，試著去拼湊輸入一條SQL指令，輕則刪掉資料庫，重則竊取全部的個資。可以說是任何一個撰寫互動式網頁的開發者首先也必要處理的問題。

![](https://fblog.ooopiz.com/images/201607/A02-02.png)

#### 防範策略：

1. 在設計應用程式時，完全使用參數化查詢（Parameterized Query）來設計資料存取功能。
2. 在組合SQL字串時，先針對所傳入的參數作字元取代（將單引號字元取代為連續2個單引號字元）。
3. 如果使用PHP開發網頁程式的話，亦可開啟PHP的魔術引號（Magic quote）功能（自動將所有的網頁傳入參數，將單引號字元取代為連續2個單引號字元）。
4. 使用其他更安全的方式連接SQL資料庫。例如已修正過SQL資料隱碼問題的資料庫連接元件，例如ASP.NET的SqlDataSource物件或是 LINQ to SQL。
5. 使用SQL防資料隱碼系統。

### A2 - Broken Authentication and Session Management (失效的驗證與連線管理)：

* 將使用者的SESSION ID曝露在URL中，我們不能保證使用者不會進行螢幕截圖或是將URL傳給任何他所認識的人，所以這是很危險的
* 未將SESSION設定Timeout時間，如果使用者在公用電腦登入卻未登出，那麼下一個使用者將可以直接以上一位使用者的身分登入
* 還有未使用SSL加密連線登入，密碼儲存時未加密等等

#### 防範策略：

1. 使用SSL加密連線機制
2. 不要將SESSION ID暴露在URL中，要有完善的SESSION保護的機制，設定一個Timeout的機制
3. 密碼儲存一定要加密。

### A3 - Cross-Site Scripting(XSS) (跨站腳本程式攻擊)：

經常發生在使用者可以輸入的欄位，例如留言板，如下圖所示，若未加防範下次有其他人瀏覽該網站時腳本隨即開始運行

![](https://fblog.ooopiz.com/images/201607/A02-03.jpg)

#### 防範策略：

1. HTML須以跳脫或編碼機制作為XSS的基本對策

```
& ---> &amp;
< ---> &lt;
> ---> &gt;
" ---> &quot;
' ---> &#x27;
/ ---> &#x2F;
```

### A4 - Insecure Direct Object References (不安全的物件參考)：

攻擊者利用網站自身的檔案讀取功能，去任意的讀取敏感資料或重要檔案，進而分析這些檔案後，達到攻破網站的目的，這個問題主要的部分在於網頁編寫時所使用的原始碼裡沒有去驗證使用者所投入的字串是否合法

#### 例如：

http://example.com/app/userInfo?userName=Ricky

透過替換userId可以任意取得用戶的資訊

#### 防範策略：

1. 網頁裡的每個物件設定正確的存取權限限制，並且在存取時確認使用者是否真的有權限存取

### A5 - Security Misconfiguration (不當的安全組態設定)：

1. 未刪除或更改所使用套件的預設帳密，攻擊者可以輕而易舉地透過嘗試法直接入侵
2. Directory listing未關閉，攻擊者可以透過此功能輕易地找出所有網站上的檔案，並且獲知你的原始碼
3. 錯誤訊息直接回傳在使用者頁面上，會透漏許多額外的訊息給予攻擊者
4. 未刪除套件所附的範例應用程式，有許多的範例都是有漏洞的

#### 防範策略：

1. 軟體和作業系統更新至最新的patch
2. 不需要的port與頁面和服務，通通關閉
3. 預設的帳密務必要進行更改
4. 控管防火牆，甚至設立黑白名單

### A6 - Sensitive Data Exposure (敏感資料暴露)：

1. 網站在與使用者傳輸敏感資料時未使用SSL加密連線，導致傳輸有可能被攔截竊聽造成使用者的帳密被盜用
2. 儲存使用者的敏感資料(例如帳密時未加密後再儲存)

#### 影響：

* 網站的管理員可以直接看到你的密碼
* 通常每個人常用的帳密通常也就是那幾組，一旦一個網站被攻破，那麼這表示許多網站都會遭受池魚之殃(假設Ａ網站帳密遭竊取，即可使用該組帳密Try B、Ｃ、Ｄ．．網站)

#### 防範策略：

1. 通通使用SSL安全連線來傳輸
2. 密碼必須使用不可逆的演算法加密後再存在資料庫裡，登入時只需比對加密後的結果是否相同。

### A7 - Missing Function Level Access Control (缺少功能級別的存取控制)：

入侵者會嘗試著去試你的網站上其他網頁的網址，而如果你不對每個頁面進行存取控制權限的要求的話，如果直接被攻擊者嘗試到你的網址，那他可以直接癱瘓你的整台主機。

#### 防範策略：

1. 正確處理不存在的網址
2. 做好認證管制，辨識身分後才能存取(沒有按鈕可以連結過去的頁面並不代表攻擊者不會手動連過去)

### A8 - Cross Site Request Forgery (CSRF) (跨站冒名請求)：

跨站請求攻擊，簡單地說，是攻擊者通過一些技術手段欺騙用戶的瀏覽器去訪問一個自己曾經認證過的網站並執行一些操作（如發郵件，發消息，甚至財產操作如轉帳和購買商品）。由於瀏覽器曾經認證過，所以被訪問的網站會認為是真正的用戶操作而去執行。這利用了web中用戶身份驗證的一個漏洞：**簡單的身份驗證只能保證請求發自某個用戶的瀏覽器，卻不能保證請求本身是用戶自願發出的**。

#### 影響：

- 假冒使用者身份在網站上購物、下單
- 假冒使用者身份在留言板上發文
- 假冒使用者身份進行帳戶處理
- 變更使用者會員資料(如密碼或電子郵件位址)
- 在網路銀行上進行授權的冒名交易

#### 例如：

* 假設這是銀行轉帳API：
  * `http://www.examplebank.com/withdraw?account=AccoutName&amount=1000&for=PayeeName`

* 惡意攻擊者在任意可執行的部位放置如下代碼：
  * `<img src="http://www.examplebank.com/withdraw?account=Alice&amount=1000&for=Badman">`

如果她之前剛訪問過銀行不久，登錄信息尚未過期，那麼她就會損失1000資金

#### 防範策略：

1. 每一次請求都傳回一個經由網站系統所雜湊出來的亂數(Token)
2. 重要交易前要求使用者重新輸入密碼
3. 重要交易後既送郵件提醒用戶，可達到儘早察覺遭受CSRF攻擊

### A9 - Using Components with Known Vulnerabilities(使用已知漏洞元件)：

現在的網站很常使用第三方的元件，但是有些時候這些元件或是函式庫其實是有問題的，就有可能會受到攻擊。

#### 防範策略：

1. 隨時關注使用的 Third Party 元件是否有漏洞揭發
2. 保持元件更新

### A10 - Unvalidated Redirects and Forwards (未經驗證的重新導向與轉送)：

通常發生在網站應用程式利用**重新導向**連結到外埠的網址，若網站網址未對重新導向的目標做進一步的驗證，攻擊者有機會設計並引誘導到惡意網址．

#### 例如：

釣魚攻擊(phishing)

利用電子郵件假造連結

![](https://fblog.ooopiz.com/images/201607/A02-01.png)

#### 防範策略：

1. 盡量避免使用redirect或forward
2. 維護一份有效的重新導向清單
3. 提醒用戶即將離開目前網站
