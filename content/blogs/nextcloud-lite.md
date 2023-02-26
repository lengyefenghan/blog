---
title: "Nextcloud轻量安装"
date: 2023-02-26T13:20:53+08:00
draft: false
---

# 前言

# 准备工作
1. 挂载硬盘
   ``` fstab
    /dev/nas/data   /mnt/data       ext4    nofail,x-systemd.device-timeout=100ms   0       0
    #外部设备在插入时挂载，在未插入时忽略。这需要 nofail 选项，可以在启动时若设备不存在直接忽略它而不报错。举个例子:
   ```
2. 安装软件包
   nginx php-fpm php-sqlite3 php-zip php-xml(dom) php-gd php-curl php-mbstring php-intl php-imagick php-bcmath
3. 下载nextcloud,并解压
   wget https://download.nextcloud.com/server/releases/latest.zip
   unzip last.zip
   chown www-data:www-data nextcloud -R
4. 配置php 

# 

