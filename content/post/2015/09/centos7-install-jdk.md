---
title: 'CentOS7 安裝JDK 64 Bit'
date: 2015-09-30T05:13:01+08:00
draft: false
---

## tar.gz 安裝

`cd /opt`

`wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz"`

`tar zxvf jdk-7u79-linux-x64.tar.gz`


```
alternatives --install /usr/bin/jar jar /opt/jdk1.7.0_79/bin/jar 2
alternatives --install /usr/bin/javac javac /opt/jdk1.7.0_79/bin/javac 2
alternatives --set jar /opt/jdk1.7.0_79/bin/jar
alternatives --set javac /opt/jdk1.7.0_79/bin/javac 
```

## rpm 安裝

### 1.下載JDK

首先到

[官方網址](http://www.oracle.com/technetwork/java/javase/downloads/index.html址)

下載你需要的JDK版本

![](https://fblog.ooopiz.com/images/201509/A05-01.png)


### 2.安裝rpm包

會自動安裝到/usr/java下

`rpm -Uvh jdk-8u25-linux-x64.rpm`


### 3.alternatives管理JDK版本

在Linux中可以同時存在許多個不同版本的JDK，方法是使用alternatives來進行管理

* alternatives的指令格式如下:  
  `alternatives –install <連結> <名稱> <路徑> <優先順序>`

`alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_25/bin/java 1`

使用alternatives檢查一下系統中的設定，因為只有一個直接按Enter即可，  
如果有兩個以上，可以選擇要使用的版本，+號即表示目前系統使用的版本

`alternatives --config java`

![](https://fblog.ooopiz.com/images/201509/A05-02.png)


### 4.檢查安裝是否正常

`java -version`

`javac -version`
![](https://fblog.ooopiz.com/images/201509/A05-03.png)


### 5.設定環境變數

設定環境變數 JAVA_HOME，將此環境變數設定在 /etc/profile

`vi /etc/profile`

最底下加上變數(JAVA_HOME目錄可能不同)

/etc/profile

```
JAVA_HOME=/usr/java/jdk1.8.0_25
CLASSPATH=./:$JAVA_HOME/lib:JAVA_HOME/jre/lib
PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
export PATH CLASSPATH JAVA_HOME
```

![](https://fblog.ooopiz.com/images/201509/A05-04.png)

### 6.reboot

可以的話reboot一下吧~

## HelloJava

HelloJava.java

```java HelloJava.java
public class HelloJava {
    public static void main(String[] args) {
        System.out.println("Hello! Java!");
    }
}
```

### 編譯
`javac HelloJava.java`

### 執行
`java HelloJava`

`java -cp . HelloJava`

(暫時不知道為什麼要這樣子才可以)

![](https://fblog.ooopiz.com/images/201509/A05-05.png)
