---
title: "hostapd开启wifi热点"
date: 2023-02-25T21:36:23+08:00
draft: false
---

1. 安装hostapd,iptables
2. 配置hostapd
   ``` conf


   ```
3. 创建nat
   ``` shell
   root# ip a
   1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether f2:d2:3a:03:ab:19 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.101/24 brd 192.168.0.255 scope global dynamic noprefixroute eth0
       valid_lft 7066sec preferred_lft 7066sec
    inet6 fe80::77be:d660:47ad:52bd/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    3: wlx90de80682540: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 90:de:80:68:25:40 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::92de:80ff:fe68:2540/64 scope link 
       valid_lft forever preferred_lft forever

    ## 分配ip地址
    ip address add 192.168.66.1/24 dev wlx90de80682540

    ## 设置转发规则
    iptables -t nat -A POSTROUTING -s 192.168.66.0/24 -o eth0 -j MASQUERADE
    ## 保存转发规则
    apt install iptables-persistent (armbian)

    ## 允许包转发
    /etc/sysctl.d/30-ipforward.conf：
      net.ipv4.ip_forward=1
      net.ipv6.conf.default.forwarding=1
      net.ipv6.conf.all.forwarding=1
    
    ##如果存在ufw
    /etc/default/ufw : default_forward_policy = "accept"
    /etc/ufw/sysctl.conf : net/ipv4/ip_forward=1 \n net/ipv6/conf/default/forwarding=1 \n net/ipv6/conf/all/forwarding=1
    

    ## udhcpd
    /etc/default/udhcpd:
      start           192.168.66.2
      end             192.168.66.254
      opt     dns     192.168.66.1 223.5.5.5
      option  subnet  255.255.255.0
      opt     router  192.168.66.1
      option  dns     192.168.66.1
   ```


