---
layout: post
title: 'php call java 類別'
date: 2016-12-21 03:23
comments: true
categories: 
---
[php-java-bridge 介紹](http://php-java-bridge.sourceforge.net/pjb/)

[php-java-bridge 載點](https://sourceforge.net/projects/php-java-bridge/)

>Files > Binary package > JavaBridgeTemplate621.war

我下載到的版本是JavaBridgeTemplate621.war

## 寫一個jar來做測試

`# mkdir TestMath`

`# cd TestMath`

`# vi TestMath.java`

```
public class TestMath {

    private Integer num1;
    private Integer num2;

    public TestMath() {
        this.num1 = 0;
        this.num2 = 0;
    }

    public TestMath(Integer n1, Integer n2) {
        this.num1 = n1;
        this.num2 = n2;
    }

    public void setNum1(Integer n) {
        this.num1 = n;
    }

    public void setNum2(Integer n) {
        this.num2 = n;
    }

    public Integer plus() {
        return num1 + num2;
    }

    public Integer minus() {
        return num1 - num2;
    }

}
```

`# javac TestMath.java`

`# touch MANIFEST.MF`

`# jar -cvfm TestMath.jar MANIFEST.MF ./`

## 佈建php/java bridge

jar放置到tomcat/lib中

`# mv TestMath.jar tomcat/lib/`

將上面下載下來的war丟掉tomcat/webapps目錄中

啟動tomcat即完成

## 寫一個php測試

require的網址必須對應你丟入的war包名稱

`# vi phpCallJava.php`

```
<?php

require_once("http://localhost:8080/JavaBridge/java/Java.inc");

//$TestMath = new java("TestMath");
$TestMath = new java("TestMath", 5, 10);

$value = $TestMath->plus();
echo $value;

$value = $TestMath->minus();
echo $value;

?>
```

`# php -n -dallow_url_include=On phpCallJava.php`

## 其他

實際放在外部機器的話必須打開防火牆

Port: 8080 & 9267
