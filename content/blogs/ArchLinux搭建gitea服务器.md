---
title: "ArchLinux搭建gitea服务器"
date: 2022-05-20T12:06:58+08:00
draft: false
tags: ["Archlinux","gitea"]
series: ["gitea"]
categories: ["Archlinux"]
---

## 安装gitea

```bash
sudo pacman -S gitea
```

## 使用 MariaDB/MySQL数据库
1. 安装数据库<br>
```bash
sudo pacman -S mariadb
```
2. 初始化数据库<br>
```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```
3. 启动数据库<br>
```bash
sudo systemctl start mariadb
sudo syetemctl enable mariadb
```
4. 安全设置<br>
```bash
sudo mysql_secure_installation
```
5. 创建数据库<br>
```bash
mysql -u root -p
mysql> CREATE DATABASE `gitea` DEFAULT CHARACTER SET `utf8mb4` COLLATE `utf8mb4_unicode_ci`;
mysql> CREATE USER `gitea`@'localhost' IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON `gitea`.* TO `gitea`@`localhost`;
mysql> FLUSH PRIVILEGES;
mysql> \q
```
6. 尝试使用新用户登录数据库<br>
```bash
mysql -u gitea -p -D gitea
```

## 初步配置gitea
1. 复制配置文件<br>
```bash
cp /etc/gitea/app.example.ini /etc/gitea/app.ini
```
2. 修改配置文件<br>
```ini
#/etc/gitea/app.ini

DB_TYPE  = mysql
HOST     = 127.0.0.1:3306 ; or /run/mysqld/mysqld.sock
NAME     = gitea
USER     = gitea
PASSWD   = password
```
3. 启动gitea<br>
```bash
systemctl start gitea
systemctl enable gitea
```
4. 测试登录<br>打开浏览器输入<br>
```url
http://ip:3000
```
5. 在页面完成初始化操作
| 项目 | 推荐值 | 说明 |
| --- | --- | --- |
| 站点名称 | gitea | 你自己的站点名称 |
| 仓库根目录 | /data/gitea(一个最好是存储盘的路径，最好热备份) | 你的仓库存储目录 |
| 服务器域名 | 这里推荐localhost 或者你的域名 | 你的服务器域名 |
| ssh服务端口 | 22 | 你的ssh服务端口 |
| 端口 | 3000 | 你的gitea服务器端口 |
| 日志目录 | /var/log/gitea | 你的日志目录 |
<br> 设置完毕后点击安装等待安装完成

## 进阶设置 通过https访问
1. 设置监听范围为本机
```ini
# /etc/gitea/app.ini
[server]
PROTOCOL                   = unix
DOMAIN                     = git.domain.tld
ROOT_URL                   = https://git.domain.tld
HTTP_ADDR                  = /run/gitea/gitea.socket
LOCAL_ROOT_URL             =

[session]
COOKIE_SECURE              = true
```
2. 添加nginx反向代理配置文件
```conf
# /etc/nginx/conf.d/gitea.conf

server {
   listen 80;
   listen [::]:80;
   server_name gitea.lengyefenghan.top;

   # Enforce HTTPS
   return 301 https://$server_name$request_uri;
}

server {
    listen 443      ssl;
    listen [::]:443 ssl;
    server_name gitea.lengyefenghan.top;
    # Path to the root of your installation


    ssl_certificate     /etc/ssl/nginx/cert.pem;
    ssl_certificate_key /etc/ssl/nginx/key.pem;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Server $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        gzip off;
        proxy_redirect off;
        proxy_buffering off;
        client_max_body_size 256M;
        proxy_pass http://unix:/run/gitea/gitea.socket;
    }
}
```
3. 重启nginx
```bash 
systemctl restart nginx
```
## 设置gitea的数据目录
1. 创建数据目录
```bash
mkdir /mnt/data/gitea
```
2. 设置目录用户和组
```bash
chown -R gitea:gitea /mnt/data/gitea
```
3. 修改servier文件
``` ini
#/etc/systemd/system/gitea.service.d/data-directory.conf

[Service]
ReadWriteDirectories=/mnt/data/gitea
```
4. 重启gitea
```bash
systemctl daemon-reload
systemctl restart gitea
```

## 开启ssh与ssh加固
``` conf 
# /etc/ssh/sshd_config

# Port 22 #注释掉port端口 改为listem ip+端口的形式
ListenAddress 0.0.0.0:22 #监听所有ipv4断22端口
ListenAddress 192.168.1.11:5022 #内网单独设置一个端口 只允许192.168.1.11的5022端口其中192.168.1.11为服务器的内网ip地址

# 强制使用公钥验证
PasswordAuthentication no #关闭密码验证
# 开启PAM认证
UsePAM yes
# 进制root用户登录
PermitRootLogin no
#添加允许gitea user登录 @host表示ip登录限制 也就是user只允许192.168.1.*的ip登录
AllowUsers gitea user@192.168.1.*
```

## 本站gitea
<a src=https://gitea.lengyefenghan.top>点我访问</a>
