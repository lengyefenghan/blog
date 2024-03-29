---
title: "阿里云LNMP环境搭建（一）-在阿里云服务器安装archlinux"
date: 2019-12-21T09:05:32Z
tags: ["archlinux","阿里云","LNMP"]
series: ["阿里云LNMP环境搭建"]
categories: ["Archlinux"]
draft: false
---

<font color=red > &emsp;&emsp;本文章具有一定时效性，最后更新时间为2019年12月19日星期四，并且会在结尾列出参考文献资料，本篇仅为开篇，后续持续更新，记得关注。</font>

<font color=green >&emsp;&emsp; LNMP环境是指Linux+nginx+mysql/mariadb+php的web服务器环境 </font>

&emsp;&emsp;文章采用arch发行版是因为本文作者使用arch发行版顺手，新手和常规用户还是建议使用ubuntu等常规发行版

# 简单叙述

&emsp;&emsp;首先下载archlinux最新版本镜像并且放在根目录
```shell
wget -o /archiso.iso https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/archlinux-2019.12.01-x86_64.iso
```
&emsp;&emsp;然后查看硬盘挂载位置

&emsp;&emsp;然后修改阿里云grub的引导文件

&emsp;&emsp;<code>/boot/grub/grub.cfg</code>文件中在第一个menuentry前添加下面的内容

```shell
set timeout=30

menuentry "Archlinux Live (x86_64)" {

    insmod iso9660
    set isofile=/archiso.iso
    loopback lo0 ${isofile}
    linux (lo0)/arch/boot/x86_64/vmlinuz archisolabel=ARCH_201912 img_dev=/dev/vda1 img_loop=${isofile} earlymodules=loop
    #其中archisolabel=ARCH_下载镜像的年月
    #其中img_dev=原来系统下的硬盘分区挂载位置
    initrd (lo0)/arch/boot/x86_64/archiso.img
}
```
&emsp;&emsp;然后重启等待进入系统，由于阿里云是vnc界面建议直接根据arch官方wiki的方法安装，其中要注意的包括：

&emsp;&emsp;1.原系统镜像挂在位于/run/archiso/img_dev

&emsp;&emsp;2.挂载好后请手动删除archiso.iso以外的文件

&emsp;&emsp;挂载磁盘：

&emsp;&emsp;# XEN 平台把 /dev/vda1 替换为 /dev/xvda1
```shell
mount -o rw,remount /dev/vda1
```
&emsp;&emsp;# 删除原有系统的文件，注意不要删除 archlinux-2016.04.01-dual.iso
```shell
cd /run/archiso/img_dev

rm -rf bin boot dev etc ...
```
之后官方安装教程可参考（不适用于新手）：

官方安装教程：https://wiki.archlinux.org/index.php/Installation_guide

# 本人安装记录
1.挂载分区可读写
```shell
mount -o rw,remount /dev/vda1
```
2.删除原有分区下多余文件，只留下原有硬盘下的archiso.iso不删除

3.验证启动方式，我这里验证不支持efi引导
```shell
ls /sys/firmware/efi/efivars
```
3.重新挂载硬盘到/mnt
```shell
mount /dev/vda1 /mnt
```
4.使用vim修改镜像源
```shell
vim /etc/pacman.d/mirrorlist
```
5.然后使用vim命令搜索
```shell
:/tuna
```
6.之后查看镜像源为清华源后使用命令将其移动到第一行后
```shell
:m 1
```
7.然后保存退出（使用大写字母ZZ快速保存退出）

8.之后使用命令安装系统
```shell
pacstrap /mnt base linux linux-firmware base-devel
```
9.生成fstab文件
```shell
genfstab -L /mnt >> /mnt/etc/fstab
```
#-L是针对MBR分区表的 -U是针对GPT分区表的

10.chroot进入系统
```shell
arch-chroot /mnt
```
11.配置系统
```shell
pacman -S grub#安装GRUB
```

12.编辑/etc/hostname填入主机名字
```shell
echo "hostname" > /etc/hostname
```
13.编辑/etc/hosts修改hosts文件

14.安装GRUB到硬盘
```shell 
grub-install --target=i386-pc /dev/vda 
```
15.生成配置文件
```shell 
grub-mkconfig -o /boot/grub/grub.cfg 
```
16.退出chroot环境
```shell 
exit
```
17.重启电脑
```shell 
Reboot
```
12.开机后进行下一步配置：
```shell
systemctl start systemd-networkd#开启网络连接,若没有错误执行下一条命令

systemctl enable systemd-networkd#设置开机自动开启网络连接

echo ‘nameserver 223.5.5.5’ > /etc/rsolv.conf#设置dns 一般不需要设置 部分情况下设置了之后会导致网络无法访问
```
&emsp;&emsp;安装基本到此结束，但是每次链接都需要从阿里云进入服务器控制台，后面会写如何开启配置ssh服务器来进行进一步配置

参考资料：

在 KVM/XEN 虚拟机上安装 Archlinux：

https://pxx.io/2016/04/04/kvm-xen-install-archlinux.html

arch官网wiki:

https://wiki.archlinux.org/
