---
title: 'Laravel 刪除套件'
date: 2015-08-24T05:04:01+08:00
draft: false
tags: ["laravel"]
---

- 1. Remove declaration from composer.json (in "require" section)
- 2. Remove Service Provider from "app/config/app.php" (reference in "providers" array)
- 3. Remove any Class Aliases from "app/config/app.php"
- 4. Remove any references to the package from your code :-)
- 5. Run "composer update"
- 6. Manually delete the published files

