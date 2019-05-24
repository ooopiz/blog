---
title: 'CentOS6.5 Tomcat開機自動啟動'
date: 2015-09-30T21:50:01+08:00
draft: false
tags: ["tomcat"]
---
### 1.設定啟動腳本
在目錄/etc/init.d新增一個tomcat的腳本
`# vi /etc/init.d/tomcat`

**記得修改你的JAVA_HOME, CATALINA_HOME到你所在的目錄下**

```
#startup script for jakarta tomcat
#
# chkconfig: - 85 20
# description: Tomcat running
# processname: tomcat7
# pidfile: /var/run/tomcat.pid # config:# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0# Set Tomcat environment.
export JAVA_HOME=/usr/java/jdk1.8.0_25
export CATALINA_HOME=/usr/local/tomcat7
export CATALINA_OPTS="-Dbuild.compiler.emacs=true"
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/lib/servlet-api.jar
export PATH=$JAVA_HOME/bin:$PATH
[ -f /usr/local/tomcat7/bin/startup.sh ] || exit 0 [ -f /usr/local/tomcat7/bin/shutdown.sh ] || exit 0
export PATH=$PATH:/usr/bin:/usr/lib/bin
# See how we were called.
case "$1" in
        start)
                # Start daemon.
                echo -n "Starting Tomcat: "
                /usr/local/tomcat7/bin/startup.sh
                RETVAL=$?
                echo
                        [ $RETVAL = 0 ] && touch /var/lock/subsys/tomcat ;;
        stop)
                # Stop daemons.
                echo -n "Shutting down Tomcat: "
                /usr/local/tomcat7/bin/shutdown.sh
                RETVAL=$?
                echo
                        [ $RETVAL = 0 ] && rm -f /var/lock/subsys/tomcat ;;
        restart)
                $0 stop
                $0 start
        ;;
        condrestart)
                [ -e /var/lock/subsys/tomcat ] && $0 restart ;;
        status)
               status tomcat
        ;;
        *)
                echo "Usage: $0 {start|stop|restart|status}"
        exit 1
esac
        exit 0
```

### 2.修改執行權限
`# chmod 755 /etc/init.d/tomcat`

### 3.增加tomcat啟動服務
`# chkconfig --add tomcat`

### 4.設定開機自動啟動
`# chkconfig tomcat on`

### 5.服務開啟關閉方式
#### 啟動服務
`# service tomcat start`
`# /etc/init.d/tomcat start`
#### 停止服務
`# service tomcat stop`
`# /etc/init.d/tomcat stop`

### 6.reboot看看吧
