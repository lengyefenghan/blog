---
title: "在Archlinux下安装nextcloud"
date: 2022-04-08T18:32:37+08:00
draft: false
tags: ["Archlinux","nextcloud"]

categories: ["Archlinux"]
---


## 概述
之前使用Alpine作为系统安装nextcloud但是手贱更新了下然后炸了，经过两天的不断尝试，最后决定使用自己比较熟悉的Archlinux作为底层系统来搭建nextcloud服务器
文章很乱 有待整理

## 用到的知识
1. pacman 的使用
2. mariadb 数据库的安装
3. php-fpm 的安装配置
4. Redis 缓存
5. zerotier-one 搭建内网穿透
6. nginx 反向代理，tcp分流

## 搭建环境

### 宿主机器

| 硬件 | 配置 |
| ---- | ---- |
| 内存 | 2G |
| cpu | n2807 |
| ssd | 256G |
| hdd | 1T |
| 家庭带宽 | 移动500M |

### vps机器 

| 硬件 | 配置 |
| ---- | ---- |
| 内存 | 512M |
| cpu | 1c1t |
| 硬盘 | 11G |
| 带宽 | 1G |
| 线路 | bwh QNET |

vps由于套了减速的cloudflare cdn所以放弃了cn2线路

## 宿主机安装

### 安装相应软件

| 软件名称 | 版本 | 
| ----- | ---- |
| nginx | 1.20.2-1 |
| docker | 1:20.10.14-1 |
| mariadb | 10.7.3-1 |
| php |
| php-fpm |
| redis |
| nextcloud |

### 配置


#### 数据库

mariadb:

建议设置为仅侦听本地 Unix 套接字


从 MariaDB 10.6.0 开始，COMPRESSED行格式的表默认为只读。这是移除写入支持和弃用该功能的第一步。
``` sh
/etc/my.cnf.d/server.cnf
```
``` conf
[mariadb-10.6] 
innodb_read_only_compressed=OFF
```
Nextcloud 自己的文档建议将事务隔离级别设置为 READ-COMMITTED。当您期望具有许多并发事务的高负载时，这一点尤其重要。
``` shell
/etc/my.cnf.d/server.cnf
```
``` conf
=
[mysqld] 
transaction_isolation=READ-COMMITTED
skip_networking
```
为nextcloud创建数据库

``` mysql
mysql -u root -p
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '你的密码';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES on nextcloud.* to 'nextcloud'@'localhost';
FLUSH privileges;
```


#### nginx 

nginx:
``` sh
/etc/nginx/http.d/nextcloud.conf
```
``` conf
upstream php-handler {
    #server 127.0.0.1:9000;
    server unix:/run/nextcloud/nextcloud.sock;
}

# Set the `immutable` cache control options only for assets with a cache busting `v` argument
map $arg_v $asset_immutable {
    "" "";
    default "immutable";
}


server {
    listen 80;
    listen [::]:80;
    server_name cloud.example.com;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443      ssl http2;
    listen [::]:443 ssl http2;
    server_name cloud.example.com;

    # Path to the root of your installation
    root /usr/share/webapps/nextcloud;

    # Use Mozilla's guidelines for SSL/TLS settings
    # https://mozilla.github.io/server-side-tls/ssl-config-generator/
    ssl_certificate     /etc/ssl/nginx/cloud.example.com.crt;
    ssl_certificate_key /etc/ssl/nginx/cloud.example.com.key;

    # HSTS settings
    # WARNING: Only add the preload option once you read about
    # the consequences in https://hstspreload.org/. This option
    # will add the domain to a hardcoded list that is shipped
    # in all major browsers and getting removed from this list
    # could take several months.
    #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;

    # set max upload size and increase upload timeout:
    client_max_body_size 512M;
    client_body_timeout 300s;
    fastcgi_buffers 64 4K;

    # Enable gzip but do not remove ETag headers
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

    # Pagespeed is not supported by Nextcloud, so if your server is built
    # with the `ngx_pagespeed` module, uncomment this line to disable it.
    #pagespeed off;

    # HTTP response headers borrowed from Nextcloud `.htaccess`
    add_header Referrer-Policy                      "no-referrer"   always;
    add_header X-Content-Type-Options               "nosniff"       always;
    add_header X-Download-Options                   "noopen"        always;
    add_header X-Frame-Options                      "SAMEORIGIN"    always;
    add_header X-Permitted-Cross-Domain-Policies    "none"          always;
    add_header X-Robots-Tag                         "none"          always;
    add_header X-XSS-Protection                     "1; mode=block" always;

    # Remove X-Powered-By, which is an information leak
    fastcgi_hide_header X-Powered-By;

    # Specify how to handle directories -- specifying `/index.php$request_uri`
    # here as the fallback means that Nginx always exhibits the desired behaviour
    # when a client requests a path that corresponds to a directory that exists
    # on the server. In particular, if that directory contains an index.php file,
    # that file is correctly served; if it doesn't, then the request is passed to
    # the front-end controller. This consistent behaviour means that we don't need
    # to specify custom rules for certain paths (e.g. images and other assets,
    # `/updater`, `/ocm-provider`, `/ocs-provider`), and thus
    # `try_files $uri $uri/ /index.php$request_uri`
    # always provides the desired behaviour.
    index index.php index.html /index.php$request_uri;

    # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
    location = / {
        if ( $http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/$is_args$args;
        }
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Make a regex exception for `/.well-known` so that clients can still
    # access it despite the existence of the regex rule
    # `location ~ /(\.|autotest|...)` which would otherwise handle requests
    # for `/.well-known`.
    location ^~ /.well-known {
        # The rules in this block are an adaptation of the rules
        # in `.htaccess` that concern `/.well-known`.

        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /remote.php/dav/; }

        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

        # Let Nextcloud's API for `/.well-known` URIs handle all other
        # requests by passing them to the front-end controller.
        return 301 /index.php$request_uri;
    }

    # Rules borrowed from `.htaccess` to hide certain paths from clients
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

    # Ensure this block, which passes PHP files to the PHP process, is above the blocks
    # which handle static assets (as seen below). If this block is not declared first,
    # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
    # to the URI, resulting in a HTTP 500 error response.
    location ~ \.php(?:$|/) {
        # Required for legacy support
        rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy) /index.php$request_uri;

        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        set $path_info $fastcgi_path_info;

        try_files $fastcgi_script_name =404;

        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param HTTPS on;

        fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
        fastcgi_param front_controller_active true;     # Enable pretty urls
        fastcgi_pass php-handler;

        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;

        fastcgi_max_temp_file_size 0;
    }

    location ~ \.(?:css|js|svg|gif|png|jpg|ico|wasm|tflite|map)$ {
        try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463, $asset_immutable";
        access_log off;     # Optional: Don't log access to assets

        location ~ \.wasm$ {
            default_type application/wasm;
        }
    }

    location ~ \.woff2?$ {
        try_files $uri /index.php$request_uri;
        expires 7d;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    # Rule borrowed from `.htaccess`
    location /remote {
        return 301 /remote.php$request_uri;
    }

    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }
}

```

``` sh
/etc/webapps/nextcloud/config/config.php
```
``` php
'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => 'cloud.example.org',
  ),    
'overwrite.cli.url' => 'https://cloud.example.org/',
'htaccess.RewriteBase' => '/',
```
#### 数据盘
不论何种方式请记得盘的挂载位置
本文中硬盘挂载在 /mnt/data
并且设置开机自动挂载
记得修改全新
``` sh
chown nextcloud:nextcloud -R /mnt/data/nextcloud
```

``` sh
/etc/webapps/nextcloud/config/config.php
```
``` php
'datadirectory' => '/mnt/data/nextcloud'
```

### php php-fpm
``` sh
/etc/php/php.ini
```
``` conf
[php]
extension=gd
extension=iconv
extension=intl
extension=mysqli
zend_extension=opcache
extension=pdo_mysql

memory_limit = 512M
upload_max_filesize = 1024M
```

``` sh
/etc/php/php-fpm.d/nextcloud.conf
```
``` conf
[nextcloud]
user = nextcloud
group = nextcloud
listen = /run/nextcloud/nextcloud.sock
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp

; should be accessible by your web server
listen.owner = http
listen.group = http

pm = dynamic
pm.max_children = 15
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```
``` sh
systemctl edit php-fpm.service
```
``` conf
[Service]
# Your data directory
ReadWritePaths=/var/lib/nextcloud/data
ReadWritePaths=/mnt/data/nextcloud
# Optional: add if you've set the default apps directory to be writable in config.php
ReadWritePaths=/usr/share/webapps/nextcloud/apps

# Optional: unnecessary if you've set 'config_is_read_only' => true in your config.php
ReadWritePaths=/usr/share/webapps/nextcloud/config

ReadWritePaths=/etc/webapps/nextcloud/config

# Optional: add if you want to use Nextcloud's internal update process
# ReadWritePaths=/usr/share/webapps/nextcloud
```
### Redis 缓存
``` sh 
/etc/php/conf.d/redis.ini
```

``` conf 
extension=redis
```

``` sh
/etc/php/conf.d/igbinary.ini
```

``` conf 
[igbinary]
extension=igbinary.so
```
``` sh
/etc/webapps/nextcloud/config/config.php
```

``` conf
'memcache.distributed' => 'OCMemcacheRedis',
'memcache.local' => 'OCMemcacheRedis',
'memcache.locking' => 'OCMemcacheRedis',
'redis' => array(
     'host' => 'localhost',
     'port' => 6379,
     ),
```

## nextcloud安装

occ maintenance:install --database mysql --database-name nextcloud --database-host localhost --database-user nextcloud --database-pass='你的密码' --data-dir /mnt/data/nextcloud

