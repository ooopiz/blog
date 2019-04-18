---
title: '利用adjtimex來修正linux時間偏差'
date: 2016-11-04 10:26
draft: false
---
##利用adjtimex來修正linux時間偏差

#####前言：

前幾天使用virtualbox安裝了一台CentOS7的虛擬機器，卻發現時間一直偏差，因此特意抓了時間下來做比對，發現大約每分鐘就會差一秒，

<img desc="" src="//imagehosting.rickyfun.net/201609/M11-A01-01.jpg">

使用虛擬機主客時間同步沒什麼效果，再考慮使用ntp來做時間校正，但因為偏差值太大，不希望校正後時間紀錄失真，

**最後採用linux本身時間糾偏的方式**

主機OS是CentOS7，因為yum無法直接安裝所以找了source code自行安裝(***感謝神同事Leo協助突破盲腸***)

---

####下載下來後選定一個版本後即可開始安裝

[GITHUB - adjtimex](https://github.com/rogers0/adjtimex/tree/master)

`# ./configure`

`# make`

`# make install`

####先了解時間差

`# adjtimex --compare` 或 `# adjtimex -c`

<img desc="" src="//imagehosting.rickyfun.net/201609/M11-A01-02.jpg">

圖中每一筆紀錄是每10秒的週期，系統有一個對tick和freq的推薦值，可以用這個對系統進行校正．

####這邊我的-t校正值是9859

`# adjtimex --tick 9859`

####再檢視一次

`# adjtimex -c`

<img desc="" src="//imagehosting.rickyfun.net/201609/M11-A01-03.jpg">

#### 這邊還有約-0.8的偏差，但其實已經相當接近，要修正更精密的差距必須用-f參數

**公式**

f = 差值 * 100000 * 65536

或

f = error_ppm平均值 * 65536

這裡 = 250 * 65536 = 16384000

####這邊我的-f校正值是16384000

`# adjtimex -f 16384000`

<img desc="" src="//imagehosting.rickyfun.net/201609/M11-A01-04.jpg">
