---
title: 'Laravel5.0 升級5.1'
date: 2015-07-25T12:22:01+08:00
draft: false
---
### 1. 修改composer.json ###
`"laravel/framework": "5.0.*"` 修改為 `"laravel/framework": "5.1.*"`

### 2. 在bootstrap目錄下建立一個目錄cache，並新增一個文件.gitignore，內容為: ###
```config .gitignore
*
!.gitignore
```

### 3. 修改bootstrap下的autoload.php ###
`$compiledPath = __DIR__.'/../vendor/compiled.php';`
修改為
`$compiledPath = __DIR__.'/cache/compiled.php';`

### 4. 執行 composer update ###
`# composer update`

### 5. 確認目錄權限###
安裝 Laravel 之後，你必須設定一些權限。<b style="color:blue">storage</b> 和 <b style="color:blue">bootstrap/cache</b> 目錄必須讓伺服器有寫入權限。
