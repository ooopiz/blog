---
title: "Vscode terminal ctrl + p 關閉 quckopen"
date: 2024-11-18T14:23:30+08:00
draft: false
tags: ["vscode"]
---

## Vscode Terminal control + p 無法切換前一個命令

常用的 terminal 工具原始設定使用 ctrl + p 熱鍵，切換到上一個命令。  
但在 vsocde 裡的 terminal 會變成 quick open  

如果想讓熱鍵可以是切到上一個命令可調整

Preferences > Setting > 搜尋框輸入 `terminal.intergrated.commandToSkipShell` > Add item `-workbench.action.quickOpen`

![vscode -workbench.action.quickOpen](https://fblog.ooopiz.com/images/2024/11/a001.png)