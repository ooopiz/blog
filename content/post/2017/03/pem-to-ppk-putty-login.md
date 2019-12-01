---
title: 'pem轉ppk putty 登入'
date: 2017-03-21T02:21:01+08:00
draft: false
---
## putty不支援openssh, 所以手上有pem檔的話需要做一次轉換

前往下載
[puttygen.exe](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

## pem 轉 ppk
1.載入pem
  
<img src="http://fblog.ooopiz.com/images/2017/m03-a01.jpg">
  
2.如果看不到檔案請選all file
  
<img src="http://fblog.ooopiz.com/images/2017/m03-a02.jpg">
  
3.載入後選擇save private key
  
<img src="http://fblog.ooopiz.com/images/2017/m03-a03.jpg">
  
4.輸入檔名生成ppk檔
  
<img src="http://fblog.ooopiz.com/images/2017/m03-a04.jpg">
  
## putty設定登入
  
1.轉換完成的ppk檔放置到你想保存的位置
  
2.開啟putty (以下為範例照自己的機器與檔案資訊填寫)
  
<img src="http://fblog.ooopiz.com/images/2017/m03-b01.jpg">
  
3.輸入用戶名稱
  
<img src="http://fblog.ooopiz.com/images/2017/m03-b02.jpg">
  
4.載入ppk檔
  
<img src="http://fblog.ooopiz.com/images/2017/m03-b03.jpg">
  
5.記得回來按一下存檔
  
<img src="http://fblog.ooopiz.com/images/2017/m03-b04.jpg">

## linux or Cmder登入方式
  
`ssh -i xxx.pem username@192.168.1.1`
  
改port的話
  
ssh -i pem路徑 用戶名稱@主機位址 -p Port端口
