---
title: "openwrt二级路由开启ipv6"
date: 2022-05-18T10:16:08+08:00
draft: false
tags: ["linux","openwrt"]
categories: ["openwrt"]
---

## 起因
因为nas之前用得是frp内网穿透方案，速度慢延迟高，且不稳定，随着ipv6的普及决定试水ipv6,路由器是新路由3，一堆固件中openwrt ipv6支持较好，所以决定折腾下ipv6

## 网络环境
| 设备 | 模式 |
| :----: | :---- |
| 光猫 | 路由模式 |
| 路由器ipv4 | 路由模式 |
| 路由器ipv6 | 中继模式(relay) |

## 光猫设置
一般情况下光猫默认ipv4,可以手动设置拨号模式为ipv4&ipv6 或者直接致电运营商要求开启ipv6
<br>检查方式:电脑确认没有关闭ipv6
<br>![win10 ipv6](/images/2022-05-18-1/win_enable_ipv6.png)
<br>然后在网络属性查看是否有240开头的ipv6地址
<br>![win10 ipv6状态](/images/2022-05-18-1/win_ipv6_status.png)
<br>到此光猫的设置就完成了

## 路由器设置
### WAN6接口设置
路由器是新路由三，固件是openwrt官方固件
<br>检查openwrt接口,如果没有wan6口需要新建一个，类型为dhcpv6客户端，接口指向WAN
<br>![创建WAN6接口](/images/2022-05-18-1/c_wan6.png)
<br>设置请求类型为try，前缀获取为自动
<br>![设置类型为dhcpv6客户端](/images/2022-05-18-1/wan6_cg.png)
<br>配置防火墙到wan
<br>![配置防火墙到wan](/images/2022-05-18-1/wan6_fw.png)
<br>设置dhcp服务ipv6开启,ipv4忽略，全部设置为中继，且勾选主接口
<br>![配置防火墙到wan](/images/2022-05-18-1/wan6_dhcpv6s.png)

### LAN接口设置
路由器lan口其他设置不变，单独更改dhcp为中继
<br>![设置lan口dhcpv6](/images/2022-05-18-1/lan-v6.png)
<font color="red">如果这时无法获取到ipv6地址，或者无法连接，尝试重启路由后无用请执行:在lan>高级设置>ipv6分配长度更改为64</font>
<br>![设置lan口前缀](/images/2022-05-18-1/lan_v6_64.png)