---
title: "Nextcloud添加aria2下载功能"
date: 2022-05-31T09:01:06+08:00
draft: false
tags: ["Linux","Nextcloud","aria2"]
series: ["Nextcloud"]
categories: ["Nextcloud"]
---

## 安装aria2
``` bash
yay -S aria2-systemd aria2
```
## 修改配置文件
1. 下载配置文件模板
``` bash
#/etc/aria2/aria2.conf.example

# 下载位置
dir=/mnt/data/Downloads/aria2

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许非外部访问, 默认:false
# 如果不需要外部访问可以关闭提升安全性
rpc-listen-all=true
# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
event-poll=epoll
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
#rpc-secret=<TOKEN>
rpc-secret=你自己的token

# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
file-allocation=trunc

#会话保存位置
input-file=/mnt/data/aria2/session.lock
save-session=/mnt/data/aria2/session.lock
```
2. 修改守护进程
``` bash
#/etc/aria2/start-daemon.sh
dir=/mnt/data/aria2;
```
3. 修改服务脚本
``` bash
#/etc/aria2/start-server.sh
dir=/mnt/data/aria2;
```

## 创建aria2 session目录并且修改下载文件保存位置权限
``` bash
mkdir -p /mnt/data/aria2
chown -R nextcloud:nextcloud /mnt/data/aria2
chown -R nextcloud:nextcloud /mnt/data/Downloads/aria2
```
## 以nextcloud用户身份启动aria2

1. 修改运行时用户身份和用户组,添加或修改以下内容
``` bash
#/usr/lib/systemd/system/aria2.service
[service]
User=nextcloud
Group=nextcloud
```
2. 运行aria2
``` bash
systemctl start aria2
systemctl enable aria2
```

# nextcloud配置
1. 添加并启用插件扩展存储
”External storage support“
2. 在插件扩展存储中添加下载目录
3. 添加扩展 下载最新版 https://github.com/e-alfred/ocdownloader/releases 然后解压到 /var/lib/nextcloud/apps 并且设置用户和组都为nextcloud
4. 应用中启用ocdownloader
5. 在设置 管理 其他设置ocdownloader 填入aria2的配置



