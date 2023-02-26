---
title: "Nextcloud踩坑记"
date: 2022-05-29T07:47:39+08:00
draft: false
tags: ["Windows","Nextcloud"]
series: ["Nextcloud"]
categories: ["Nextcloud"]
---

## Windows下无法同步文件夹
1. 文件夹大小写区分问题
在windows下默认文件夹不区分大小写，也就是"test"和"TEST"是同一个文件夹，如果想要同步文件夹，需要设置文件夹大小写区分
``` powershell
# 查询文件夹大小写区分
fsutils.exe file queryCaseSensitiveInfo PATH
# 设置区分大小写
fsutils.exe file setCaseSensitiveInfo PATH enable
# 设置不区分文件大小写
fsutils.exe file setCaseSensitiveInfo PATH disable
```
<font color="red">注意:此处设置的路径并不会传递到下一级目录，也就是'D:\Nextcloud'目录被设置为区分大小写，但是'D\Nextcloud\Downloads'目录下又不会区分大小写，所以需要设置'D:\Nextcloud\Downloads'时路径必须是他，而不是上一级目录</font>

## 更新后提示权限错误或者无法启动
1. 查看nginx运行日志,此处网页错误id IBdcJOfunqHjhcnOBr9S
``` sh
systemctl status nginx.service | grep IBdcJOfunqHjhcnOBr9S
Jun 24 08:58:25 cloud.lengyefenghan.top nginx[2911]: 2022/06/24 08:58:25 [error] 2911#2911: *3 FastCGI sent in stderr: "PHP message: {"reqId":"IBdcJOfunqHjhcnOBr9S","level":3,"time":"2022-06-24T00:58:25+00:00","remoteAddr":"127.0.0.1","user":"--","app":"PHP","method":"GET","url":"/","message":"touch(): Unable to create file /usr/share/webapps/nextcloud/config/config.php because Permission denied at /usr/share/webapps/nextcloud/lib/private/Config.php#263","userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36","version":"","exception":{"Exception":"Error","Message":"touch(): Unable to create file /usr/share/webapps/nextcloud/config/config.php because Permission denied at /usr/share/webapps/nextcloud/lib/private/Config.php#263","Code":0,"Trace":[{"function":"onError","class":"OC\\Log\\ErrorHandler","type":"::"},{"file":"/usr/share/webapps/nextcloud/lib/private/Config.php","line":263,"function":"touch"},{"file":"/usr/share/webapps/nextcloud/lib/private/Config.php","line":143,"function":"writeData","class":"OC\\Config","type":"->"},{"file":"/usr/shar...PHP message: {"reqId":"IBdcJOfunqHjhcnOBr9S","level":3,"time":"2022-06-24T00:58:25+00:00","remoteAddr":"127.0.0.1","user":"--","app":"PHP","method":"GET","url":"/","message":"fopen(/usr/share/webapps/nextcloud/config/config.php): Failed to open stream: Permission denied at /usr/share/webapps/nextcloud/lib/private/Config.php#264","userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36","version":"","exception":{"Exception":"Error","Message":"fopen(/usr/share/webapps/nextcloud/config/config.php): Failed to open stream: Permission denied at /usr/share/webapps/nextcloud/lib/private/Config.php#264","Code":0,"Trace":[{"function":"onError","class":"OC\\Log\\ErrorHandler","type":"::"},{"file":"/usr/share/webapps/nextcloud/lib/private/Config.php","line":264,"function":"fopen"},{"file":"/usr/share/webapps/nextcloud/lib/private/Config.php","line":143,"function":"writeData","class":"OC\\Config",
Jun 24 08:58:25 cloud.lengyefenghan.top nginx[2911]: 2022/06/24 08:58:25 [error] 2911#2911: *3 FastCGI sent in stderr: "PHP message: {"reqId":"IBdcJOfunqHjhcnOBr9S","level":3,"time":"2022-06-24T00:58:25+00:00","remoteAddr":"127.0.0.1","user":"--","app":"PHP","method":"GET","url":"/","message":"fopen(/usr/share/webapps/nextcloud/data/nextcloud.log): Failed to open stream: No such file or directory at /usr/share/webapps/nextcloud/lib/private/Log/File.php#84","userAgent":"Mozilla/5.0 (W" while reading upstream, client: 127.0.0.1, server: cloud.lengyefenghan.top, request: "GET / HTTP/2.0", upstream: "fastcgi://unix:/run/nextcloud/nextcloud.sock:", host: "cloud.lengyefenghan.top"
```
根据错误可知是权限问题，通过chmod 775 -R config可以修正，但是此处修正后仍然提示错误，经过检查是php-fpm配置文件丢失，在上一篇文章 [在Archlinux下安装nextcloud](https://lengyefenghan.top/blogs/2022-04-08-1/) 中修改的php-fpm进行的操作丢失，重新操作后恢复正常


## nginx 您的网页服务器未正确设置以解析carddav caldav

``` conf
location ^~ /.well-known {
        # The rules in this block are an adaptation of the rules
        # in `.htaccess` that concern `/.well-known`.

        location = /.well-known/carddav { return 301 $scheme://$host/remote.php/dav/; }
        location = /.well-known/caldav  { return 301 $scheme://$host/remote.php/dav/; }

        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

        # Let Nextcloud's API for `/.well-known` URIs handle all other
        # requests by passing them to the front-end controller.
        return 301 /index.php$request_uri;
    }
```

## 此实例中的 php-imagick 模块不支持 SVG。为了获得更好的兼容性，建议安装它
 安装libmagickcore-6.q16hdri-6-extra


## fwrite() expects parameter 1 to be resource, bool given in file '/var/www/nextcloud/lib/private/Security/CertificateManager.php

修改nextcloud data目录权限不一致的目录 750


# 调整nextcloud分片上传
为了在上传带宽较高的环境中提升上传性能，可以调整服务器的上传块大小：
sudo -u www-data php occ config:app:set files max_chunk_size --value 20971520
输入一个以字节为单位的值（在本例中为 20MB）。设置为完全不分块。--value 0

默认值为 10485760 (10 MiB)。

``` sh
 #关闭分片大小
sudo --user=www-data php /var/www/nextcloud/occ config:app:set files max_chunk_size --value 0
#如果开启apcu
sudo --user=www-data php --define apc.enable_cli=1 /var/www/nextcloud/occ config:app:set files max_chunk_size --value 0
```

# 文件上传一段时间没有速度 之后失败
调整缓存位置
php/pool.d/www.conf

```
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
```
   修改合适路径

# 扫描本地文件更改

``` sh
sudo --user=www-data php /var/www/nextcloud/occ files:scan --all
```

# 定时任务

/etc/systemd/system/nextcloudcron.service

``` ini
[Unit]
Description=Nextcloud cron.php job

[Service]
User=www-data
ExecStart=/usr/bin/php -f /var/www/nextcloud/cron.php
KillMode=process
```

/etc/systemd/system/nextcloudcron.timer

``` ini
[Unit]
Description=Run Nextcloud cron.php every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Unit=nextcloudcron.service

[Install]
WantedBy=timers.target
```

开启

``` sh
systemctl enable --now nextcloudcron.timer
```

# 优化数据库性能

``` sh
$ mariadb -u root -p
SHOW VARIABLES like '%flush%';
```

以下引用：

https://cloud.tencent.com/developer/article/1441303

innodb_flush_log_at_trx_commit 和 sync_binlog 是 MySQL 的两个配置参数。它们的配置对于 MySQL 的性能有很大影响（一般为了保证数据的不丢失，会设置为双1，该情形下数据库的性能也是最低的）。

1. innodb_flush_log_at_trx_commit
innodb_flush_log_at_trx_commit：是 InnoDB 引擎特有的，ib_logfile的刷新方式（ ib_logfile：记录的是redo log和undo log的信息）
取值:0/1/2
innodb_flush_log_at_trx_commit=0，表示每隔一秒把log buffer刷到文件系统中(os buffer)去，并且调用文件系统的“flush”操作将缓存刷新到磁盘上去。也就是说一秒之前的日志都保存在日志缓冲区，也就是内存上，如果机器宕掉，可能丢失1秒的事务数据。
innodb_flush_log_at_trx_commit=1，表示在每次事务提交的时候，都把log buffer刷到文件系统中(os buffer)去，并且调用文件系统的“flush”操作将缓存刷新到磁盘上去。这样的话，数据库对IO的要求就非常高了，如果底层的硬件提供的IOPS比较差，那么MySQL数据库的并发很快就会由于硬件IO的问题而无法提升。
innodb_flush_log_at_trx_commit=2，表示在每次事务提交的时候会把log buffer刷到文件系统中去，但并不会立即刷写到磁盘。如果只是MySQL数据库挂掉了，由于文件系统没有问题，那么对应的事务数据并没有丢失。只有在数据库所在的主机操作系统损坏或者突然掉电的情况下，数据库的事务数据可能丢失1秒之类的事务数据。这样的好处，减少了事务数据丢失的概率，而对底层硬件的IO要求也没有那么高(log buffer写到文件系统中，一般只是从log buffer的内存转移的文件系统的内存缓存中，对底层IO没有压力)。
2. sync_binlog
sync_binlog：是MySQL 的二进制日志（binary log）同步到磁盘的频率。
取值：0-N
sync_binlog=0，当事务提交之后，MySQL不做fsync之类的磁盘同步指令刷新binlog_cache中的信息到磁盘，而让Filesystem自行决定什么时候来做同步，或者cache满了之后才同步到磁盘。这个是性能最好的。
sync_binlog=1，当每进行1次事务提交之后，MySQL将进行一次fsync之类的磁盘同步指令来将binlog_cache中的数据强制写入磁盘。
sync_binlog=n，当每进行n次事务提交之后，MySQL将进行一次fsync之类的磁盘同步指令来将binlog_cache中的数据强制写入磁盘。

注：
大多数情况下，对数据的一致性并没有很严格的要求，所以并不会把 sync_binlog 配置成 1. 为了追求高并发，提升性能，可以设置为 100 或直接用 0. 
而和 innodb_flush_log_at_trx_commit 一样，对于支付服务这样的应用，还是比较推荐 sync_binlog = 1.

所以设置配置文件即可 
``` ini
[global]
innodb_flush_log_at_trx_commit = 0 1 2 三个值选其中一个
sync_binlog = 100 
```

# nas因硬盘故障无法正常开机

外部设备在插入时挂载，在未插入时忽略。这需要 nofail 选项，可以在启动时若设备不存在直接忽略它而不报错。举个例子:

``` fstab
    /dev/nas/data   /mnt/data       ext4    nofail,x-systemd.device-timeout=100ms   0       0

```