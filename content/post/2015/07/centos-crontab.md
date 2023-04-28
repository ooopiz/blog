---
title: 'CentOS crontab'
date: 2015-07-27T01:35:01+08:00
draft: false
tags: ["centos"]
---

## Example

輸入 `crontab -e` 進入排程編輯

```
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
```

## Instruction

| 特殊字符 | 代表意義 |
|--- |--- |
| *(星號) | 代表任何時刻都接受的意思！舉例來說，範例一內那個日、月、週都是 `*`，就代表著『不論何月、何日的禮拜幾的 12:00 都執行後續指令』的意思！ |
| ,(逗號) | 代表分隔時段的意思。舉例來說，如果要下達的工作是 3:00 與 6:00 時，就會是： `0 3,6 * * * command` 時間參數還是有五欄，不過第二欄是 3,6 ，代表 3 與 6 都適用！ |
| -(減號) | 代表一段時間範圍內，舉例來說， 8 點到 12 點之間的每小時的 20 分都進行一項工作： `20 8-12 * * * command` 仔細看到第二欄變成 8-12 喔！代表 8,9,10,11,12 都適用的意思！ |
| /n(斜線) | 那個 n 代表數字，亦即是『每隔 n 單位間隔』的意思，例如每五分鐘進行一次，則：`*/5 * * * * command` 很簡單吧！用 * 與 /5 來搭配，也可以寫成 0-59/5 ，相同意思！ |


crontab 產生的訊息會存放在 `/var/spool/mail/root`
