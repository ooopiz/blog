---
layout: post
title: 'Laravel 刪除套件'
date: 2015-08-24 05:04
comments: true
categories: 
---

###	1. Remove declaration from composer.json (in "require" section)
###	2. Remove Service Provider from "app/config/app.php" (reference in "providers" array)
###	3. Remove any Class Aliases from "app/config/app.php"
###	4. Remove any references to the package from your code :-)
###	5. Run "composer update"
###	6. Manually delete the published files

