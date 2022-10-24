---
title: "阿里云LNMP环境搭建（三）-搭建lnmp并测试"
date: 2019-12-21T11:39:56Z
draft: false
tags: ["archlinux","阿里云","LNMP"]
series: ["阿里云LNMP环境搭建"]
categories: ["Archlinux"]
---

<font color=red>&emsp;&emsp;本文章具有一定时效性，最后更新时间为2019年12月20日星期五，并且会在结尾列出参考文献资料，本篇仅为后篇，后续更新其他相关，记得关注。</font>

1.安装nginx php mariadb
```shell
pacman -S nginx mariadb mariadb-libs php-fpm php-gd
#php-fpm php-gd是需要的两个php模块
```
2.配置数据库
```shell
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

#需要以root权限运行

systemctl start mariadb #开启数据库服务端

systemctl enable mariadb #设置开机启动

mysql_secure_installation

#设置安全组策略第一个是询问MariaDB的root密码，没有设置密码就可以直接按Enter键，再设置一个root密码。之后，第一个问答输入y他会删除test数据库，第二个问答是是否删除anonymous用户以及最后一个禁用用root用户远程登录。
```
3.启用nginx
```shell
systemctl start nginx#启用

systemctl enable nginx#设置开机启动
```
&emsp;&emsp;之后浏览器打开网址http://server-ip:80/查看，会看到nginx的欢迎界面

&emsp;&emsp;如果绑定域名用于名访问提示服务器不存在很正常，因为你还没有正确的配置nginx

4.接下来进入进阶型配置，而非默认配置。

4.1首先关掉nginx服务
```shell
systemctl stop nginx
```
4.2然后进入到nginx配置文件目录
```shell
cd /etc/nginx
```
4.3备份配置及文件
```shell
mv nginx.conf nginx.conf.bak
```
4.4新建配置文件 /etc/nginx/nginx.conf并编辑内容如下
```shell
user http;

 

# May be equal to `grep processor /proc/cpuinfo | wc -l`

worker_processes auto;

worker_cpu_affinity auto;

 

# PCRE JIT can speed up processing of regular expressions significantly.

pcre_jit on;

 

events {

    # Should be equal to `ulimit -n`

    worker_connections 1024;

 

    # Let each process accept multiple connections.

    multi_accept on;

 

    # Preferred connection method for newer linux versions.

    use epoll;

}

 

http {

    server_tokens off; # Disables the “Server” response header

    charset utf-8;

 

    # Sendfile copies data between one FD and other from within the kernel.

    # More efficient than read() + write(), since the requires transferring

    # data to and from the user space.

    sendfile on;

 

    # Tcp_nopush causes nginx to attempt to send its HTTP response head in one

    # packet, instead of using partial frames. This is useful for prepending

    # headers before calling sendfile, or for throughput optimization.

    tcp_nopush on;

 

    # Don't buffer data-sends (disable Nagle algorithm). Good for sending

    # frequent small bursts of data in real time.

    #

    tcp_nodelay on;

 

    # On Linux, AIO can be used starting from kernel version 2.6.22.

    # It is necessary to enable directio, or otherwise reading will be blocking.

    # aio threads;

    # aio_write on;

    # directio 8m;

 

    # Caches information about open FDs, freqently accessed files.

    # open_file_cache max=200000 inactive=20s;

    # open_file_cache_valid 60s;

    # open_file_cache_min_uses 2;

    # open_file_cache_errors on;

 

    # http://nginx.org/en/docs/hash.html

    types_hash_max_size 4096;

    include mime.types;

    default_type application/octet-stream;

 

    # Logging Settings

    access_log off;

 

    # Gzip Settings

    gzip on;

    gzip_comp_level 6;

    gzip_min_length 500;

    gzip_proxied expired no-cache no-store private auth;

    gzip_vary on;

    gzip_disable "MSIE [1-6]\.";

    gzip_types

        application/atom+xml

        application/javascript

        application/json

        application/ld+json

        application/manifest+json

        application/rss+xml

        application/vnd.geo+json

        application/vnd.ms-fontobject

        application/x-font-ttf

        application/x-web-app-manifest+json

        application/xhtml+xml

        application/xml

        font/opentype

        image/bmp

        image/svg+xml

        image/x-icon

        text/cache-manifest

        text/css

        text/plain

        text/vcard

        text/vnd.rim.location.xloc

        text/vtt

        text/x-component

        text/x-cross-domain-policy;

 

    # index index.php index.html index.htm;

    include sites-enabled/*; # See Server blocks

}
```
4.5上面的配置文件并没有定义任何服务，所以即使启用也无法访问，接下来要使用多个配置文件
```shell
mkdir /etc/nginx/sites-available#新建模块文件放的位置

mkdir /etc/nginx/sites-enabled#模块文件启用的目录
```

4.6进入到模块文件夹
```shell
cd /etc/nginx/sites-available
```
4.7编辑/etc/nginx/sites-available/example文件创建一个示例代码块
```shell
server {

        listen 80;

        listen [::]:80;

        server_name server_url/name/ip;#可以是ip、域名、等等，本地调试请改为127.0.0.1

        root /usr/share/nginx/html;

        location / {

           index index.php index.html index.htm;

        }

}
```
4.8启用代码块只需要简单的创建一个符号链接：
```shell
ln -s /etc/nginx/sites-available/example /etc/nginx/sites-enabled/example
```
&emsp;&emsp;取消代码块
```shell
unlink /etc/nginx/sites-enabled/example
```
&emsp;&emsp;添加代码块或者修改配置只需要重启nginx就可以了
```shell
systemctl restart nginx
```
5.配置php

&emsp;&emsp;修改php配置文件启用模块

&emsp;&emsp;编辑<code>/etc/php/php.ini</code>文件：
```shell
extension=gd.so

extension=pdo_mysql.so

extension=mysqli.so
```
6.启用php-fpm
```shell
systemctl start php-fpm

systemctl enable php-fpm
```
7.在nginx配置模块里启用php
```shell
/etc/nginx/sites-available/php-test

server {

    listen 8000;

    listen [::]:8000;

server_name server_url/name/ip;#可以是ip、域名、等等，本地调试请改为127.0.0.1

root /usr/share/nginx/html;

    location / {

        index test.php index.html index.htm;

    }

 

    location ~ [^/]\.php(/|$) {

        # Correctly handle request like /test.php/foo/blah.php or /test.php/

        fastcgi_split_path_info ^(.+?\.php)(/.*)$;

 

        try_files $uri $document_root$fastcgi_script_name =404;

 

        # Mitigate https://httpoxy.org/ vulnerabilities

        fastcgi_param HTTP_PROXY "";

 

        fastcgi_pass unix:/run/php-fpm/php-fpm.sock;

        fastcgi_index index.php;

        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

        include fastcgi_params;

    }

}
```
8.在/usr/share/nginx/html下新建test.php
```php
<?php phpinfo(); ?>
```
&emsp;&emsp;之后link启用模块
```shell
ln -s /etc/nginx/sites-available/php-test /etc/nginx/sites-enabled/php-test
```
&emsp;&emsp;然后重启nginx
```shell
systemctl restart nginx
```
<font color=green>
&emsp;&emsp;浏览器地址栏访问，这个时候需要注意三点

&emsp;&emsp;&emsp;&emsp;a.一共使用了两个web端口80和8000，两个一个是html的静态，另一个是可以使用php的动态，访问时需要区分

&emsp;&emsp;&emsp;&emsp;b.本地访问一般都可以，服务器访问需要开启端口阿里云的配置文档非常详细了，这里给个链接：<a href="https://help.aliyun.com/document_detail/25471.html">https://help.aliyun.com/document_detail/25471.html</a>

&emsp;&emsp;&emsp;&emsp;c.访问的时候注意代码模块test.php中代码index设定的为主页，指定第一加载php文件为test.php
</font>
&emsp;&emsp;访问的两个地址：

&emsp;&emsp;&emsp;&emsp;a.<a>http://server_name:80/</a> #指向静态加载，也是默认加载

&emsp;&emsp;&emsp;&emsp;b.<a>http://server_name:8000/</a> #指向动态加载

9.最后测试phpmyadmin搭建和测试

9.1首先安装phpmyadmin
```shell
pacman -S phpmyadmin
```
9.2然后创建phpmyadmin 的nginx配置文件(基于php-test改就行了)

&emsp;&emsp;<code>/etc/nginx/sites-available/phpmyadmin</code>
```shell
server {

    listen 888;

    listen [::]:888;

server_name server_url/name/ip;#可以是ip、域名、等等，本地调试请改为127.0.0.1

root /srv/http/phpmyadmin;#修改web目录

    location / {

        index index.php index.html index.htm;#设置为index.php

    }

 

    location ~ [^/]\.php(/|$) {

        # Correctly handle request like /test.php/foo/blah.php or /test.php/

        fastcgi_split_path_info ^(.+?\.php)(/.*)$;

 

        try_files $uri $document_root$fastcgi_script_name =404;

 

        # Mitigate https://httpoxy.org/ vulnerabilities

        fastcgi_param HTTP_PROXY "";

 

        fastcgi_pass unix:/run/php-fpm/php-fpm.sock;

        fastcgi_index index.php;

        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

        include fastcgi_params;

    }

}
```
9.3接下来设置web权限
9.3.1链接phpmyadmin到/srv/http
```shell
ln -s /usr/share/webapps/phpMyAdmin /srv/http/phpmyadmin
```
9.3.2使用安装脚本
```shell
mkdir /usr/share/webapps/phpMyAdmin/config #创建配置文件文件夹

chown http:http /usr/share/webapps/phpMyAdmin/config #用户组使可以网页端访问

chmod 750 /usr/share/webapps/phpMyAdmin/config #修改权限保证安全
```
9.4输入网址http://server:888/访问
<font color=green>

BUG：

&emsp;&emsp;1.配置文件现在需要一个短语密码，修改配置文件,中间char必须是32个字符
<code>
/etc/webapps/phpmyadmin/config.inc.php
</code>
```shell
$cfg['blowfish_secret'] = 'char';
```
&emsp;&emsp;2.错误提示：安装时所用的 config 文件夹尚未删除。我们强烈建议您在完成 phpMyAdmin 安装后立即删除该文件夹。否则未经授权的用户都可以下载您的配置文件从而使服务器陷入危险。
```shell
rm -rf /usr/share/webapps/phpMyAdmin/config #删除创建的配置文件文件夹
```
</font>

到此基本lnmp的环境已经搭建完成了
