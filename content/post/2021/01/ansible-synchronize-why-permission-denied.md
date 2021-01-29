---
title: "Ansible Synchronize Why Permission Denied"
date: 2021-01-28T15:37:22+08:00
draft: false
tags: ["ansible"]
---

## 關於 ansible 的 Synchronize 模組問題

關於 ansible 的使用上，synchroize 是一個很棒的模組，  
如果大量的檔案想要複製到目標機器上的話，也許有其他模組可以達到類似的需求，  
但以效能來說，synchroize 這個模組大概會是首選，因為其底層是透過 rsync 的指令傳輸資料。  

不過 synchroize 這個模組卻是時靈時不靈。  
筆者有一陣子很困擾的問題是，為什麼整份 ansible script 已經測試那麼多次了。  
執行到有 synchroize 這個模組有時還是會報出 permission deied。  

become_user: root, become_method: sudo, 跟模組參數試了又試。  
還是很難理解到底那個環節出了問題。  

![](https://fblog.ooopiz.com/images/2021/01/a001.jpg)

## 發現問題

一般來說 ansible 使用上都是透過 ssh 控制遠程的目標伺服器。  
筆者的 asnible script 寫了很多安裝佈署的步驟，其中當然也包含了 synchroize 模組。  

為了符合單機離線安裝的情境，做這類佈署時我會直接將 inventory 的主機直接指定本地端的 IP，  
直接在本地執行安裝腳本。

一台 Server 可能會有多個網卡跟IP（127.0.0.1 or 192.168.x.x）  
就在某次我將 inventory 目標主機指定成 127.0.0.1 果然發生一樣的問題。  

當我發現目標機器是 127.0.0.1 時就會出問題，  
目標機器 是 192.168.1.10 (一樣是本地端IP) 卻是正常的。  

我大概可以猜測 synchroize 模組針對 localhsot or 127.0.0.1 的目標機器可能有不同的處理流程

## 測試

### 1. 先寫了一個 playbook 來 play 測試一下

```
---
- name:
  hosts: all
  become: yes
  become_user: root
  become_method: sudo
  gather_facts: false

  tasks:
    - name: 'rsync migrations dist dir'
      synchronize:
        src:  "{{ lookup('env', 'PWD') }}/dist/"
        dest: "/var/lib/migrations/dist/"
        delete: yes
        rsync_opts:
          - "--chown=ricky:ricky"
```

### 2. 接著在 synchroize 模組源碼中，追蹤到兩個明確的變數差異

* target: 127.0.0.1
  ```
  {'src': '/home/ubuntu/test/dist/', 'dest': '/var/lib/migrations/dist/', 'delete': True, '_local_rsync_path': 'rsync', '_local_rsync_password': '123456', 'rsync_path': 'sudo rsync'}
  ```

* target: 192.168.56.103
  ```
  {'src': '/home/ubuntu/test/dist/', 'dest': 'ubuntu@192.168.56.103:/var/lib/migrations/dist/', 'delete': True, '_local_rsync_path': 'rsync', '_local_rsync_password': '123456', 'rsync_path': 'sudo rsync'}
  ```

### 3. 推測 ansible 具體執行的指令

* target: 127.0.0.1

  `rsync /home/ubuntu/test/dist/ /var/lib/migrations/dist/`

* target: 192.168.56.103

  `rsync /home/ubuntu/test/dist/ ubuntu@192.168.56.103:/var/lib/migrations/dist/`

### 4. 追蹤導致上方變數不同的原因 (plugins/action/synchronize.py)

在源碼中插入 debug message（7, 8, 9, z, 等...）

> 這段程式碼有一連串在判斷目標機器是否是 local 的邏輯

![](https://fblog.ooopiz.com/images/2021/01/a003.jpg)

執行結果左邊目標是 127.0.0.1  
右邊目標是 192.168.56.103  

可以發現變數具體被改變的地方在 8～9 號之間

![](https://fblog.ooopiz.com/images/2021/01/a002.jpg)

直接看了一下 self._process_remote 的 function  
可以知道在這個狀況下 C.LOCALHOST 應該是起了決定性的作用  

![](https://fblog.ooopiz.com/images/2021/01/a004.jpg)

找到 C.LOCALHOST 定義的地方 ( constants.py )  

![](https://fblog.ooopiz.com/images/2021/01/a005.jpg)

## 結論

原本預期當 inventory 指定 127.0.0.1 時  
所有的 task 均會透過 `ssh ubuntu@127.0.0.1` 執行腳本，  

事實上在 Synchronize 這個模組運行時，卻是將其視為 locally 的操作，  
也就是 rsync local-dir local-dir  

因此 become_sudo 跟 become_user 的無效化造成 permission denied 也算是稍微可以理解。  
