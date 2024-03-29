---
title: "ArchLinux Hyper-v下双网卡配置"
date: 2022-05-20T12:06:54+08:00
draft: false
tags: ["Archlinux","Hyper-v"]
series: ["Hyper-v"]
categories: ["Archlinux"]
---

## 外网网卡配置文件

外网eth0，由hyper-v进行NAT转发，使用hyprt-v自带默认网络交换机
```ini
[Match]
Name=eth0

[Network]
DHCP=ipv4
```
## hyper-v配置内网网卡
1. 首先在huper-v创建一张内部专用网卡<br>![添加网卡](/images/2022-05-20/LAN-switch.png)
2. 在网络设备管理器里面手动指定一个ip<br>![指定ip](/images/2022-05-20/LAN-SET.png)

## 内网网卡配置文件

内网eth1，用于设置内网静态IP，方便内网ssh链接

```ini
[Match]
Name=eth1

[Network]
Address=192.168.10.66/24
#Gateway=192.168.10.1 注释掉gateway 也就是网关，这样子双网卡都使用第一张网卡的默认网关，否则需要添加路由表来解决无法上网问题
DNS=192.168.10.1
```