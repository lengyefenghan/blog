---
title: "lnmp安装filerun"
date: 2022-11-06T12:43:39+08:00
draft: false
---

# 前言
<font color='Red'> !!! 注意FileRun 软件开发者思维脑回路跟一些人不同 可能存在脑筋急转弯 最起码我是很无语,所以本文章只写到http部署结尾 卡在ssl加密 !!!</font>
FileRun是一个类似于Nextcloud的PHP网盘程序，但是由于我不考虑多用户所以就换成了filerun(实际上刷修nc部署后的各种问题修麻了).
然后就是FileRun要比nextcloud轻量，部署也简单一点。FileRun在安卓使用nextcloud的客户端，所以说使用没有多少区别。

<font color='Red'> 注意FileRun是非开源软件,介意的人可以放弃这个</font>

### 特殊工作(清除旧的nextcloud 配置)
<font color='Red'> 注意这里是因为之前装nc折腾的乱七八糟</font>
1. 移除旧的php.ini php-fpm.ini pool.d/www.conf文件
2. 下载安装包提取配置文件
3. 测试配置 关闭nextcloud的定时任务
4. 删除无用的 postgresql
5. 清除nextcloud的数据库
   
# 开始安装

## 下载最新版本
``` sh
    # 到下载目录
    cd /var/www
    #创建文件夹
    mkdir filerun
    cd filerun
    # 下载最新版
    wget https://filerun.com/download-latest -O FileRun.zip
    # 下载解压文件
    wget https://f.afian.se/wl/?id=HS&mode=grid&download=1 -o unzip.php
    # 修改用户和组
    chown www-data:www-data /var/www/filerun -R  
```
## 配置nginx
```conf
server {
    listen 80;
    server_name cloud.example.com;

    # 网站根目录    
    root /var/www/filerun;

    #以下配置来自filerun官方demo
    location ~ [^/]\.php(/|$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }

        # Mitigate https://httpoxy.org/ vulnerabilities
        #fastcgi_param HTTP_PROXY "";
        
        # 此处修改为正确的fastcgi地址            
        fastcgi_pass  unix:/var/run/php/php7.4-fpm.sock;
        #fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;

        # include the fastcgi_param setting
        include fastcgi_params;

        # SCRIPT_FILENAME parameter is used for PHP FPM determining
        #  the script name. If it is not set in fastcgi_params file,
        # i.e. /etc/nginx/fastcgi_params or in the parent contexts,
        # please comment off following line:
        # fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;

        #确保以下代码没有注释掉        
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```
### 配置数据库mysql
1. 安装数据库
2. 创建数据库
``` sh
mysql -u root -p
CREATE DATABASE filerun CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON filerun.* TO filerun@localhost IDENTIFIED BY '设置你的数据库用户密码';
FLUSH PRIVILEGES;
quit

```
## 配置php
1. 前往http://www.ioncube.com/loaders.php根据自己的版本下载ionCube
2. 解压到/usr/local
3. 修改php.ini文件添加ioncube 注意版本
   ``` sh
   echo 'zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.4.so' >> /etc/php/7.4/fpm/php.ini 
   ```
4. 测试是否正常安装
   在filrun的目录添加一个php文件 重启php-fpm后访问查看是否正常加载
   ```php
   <?php phpinfo ( ) ;
   ```

## 创建数据目录
path是你的数据目录
```sh
mkdir -p path
chown www-data:www-data path
```
## 访问域名进行安装
1. 访问 http://站点/unzip.php
2. 完成检查项目
3. 填写数据库信息
4. 记录下账户密码
5. 根据提示首次完成账户密码等信息的修改
6. 请为你的网站开启域名访问一定要是http
7. 根据设置最下面 listen 提交邮件信息完成软件注册
8. 然后返回设置 interface 下载语言文件 论坛账户密码请自行前往邮件查看
9. 设置下权限里面的路径，基本完成安装

## 开启ssl
研究失败放弃部署

