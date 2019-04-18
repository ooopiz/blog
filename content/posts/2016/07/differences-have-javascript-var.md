---
title: 'javascript 有沒有var的差別'
date: 2016-07-21 14:54
draft: false
---
<p style="color:red">有沒有var差很大啊，要注意</p>

## Output is "7"
```
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


## x is not defined
```
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
