---
title: 'javascript 有沒有var的差別'
date: 2016-07-21T14:54:01+08:00
draft: false
---

有沒有var差很大啊，要注意

Output is "7"
  
```js
$(document).ready(function () {
    x = 6;
});
$(document).ready(function () {
    x = 7;
});
$(document).ready(function () {
    alert(x);
});
```

x is not defined
  
```js
$(document).ready(function () {
    var x = 6;
});
$(document).ready(function () {
    var x = 7;
});
$(document).ready(function () {
    alert(x);
});
```
