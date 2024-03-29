---
title: "阿里云LNMP环境搭建（二）-配置archlinux"
date: 2019-12-21T10:29:36Z
draft: false
tags: ["archlinux","阿里云","LNMP"]
series: ["阿里云LNMP环境搭建"]
categories: ["Archlinux"]
---

<font color=red>&emsp;&emsp;本文章具有一定时效性，最后更新时间为2019年12月20日星期五，并且会在结尾列出参考文献资料，本篇仅为中篇，后续持续更新，记得关注。</font>

1.首先要配置的是ssh
```shell
pacman -S openssh#安装ssh
```
1.1 编辑<code>/etc/ssh/sshd_config</code>ssh服务器端配置文件，仅记录本人修改项目
```shell
Port 22#ssh的端口，阿里云默认22端口且仅允许22端口使用ssh协议，修改后可能会出现问题

PermitRootLogin yes#允许root用户登陆，一般建议更改为no并且另外添加用户
```
1.2 开启ssh服务端
```shell
systemctl start sshd#开启ssh服务端

systemctl enable sshd#若正常开启服务端，则使用这条命令设置为开机启动
```
1.3 然后通过ssh root@服务器端ip连接服务器

&emsp;&emsp;注意：为了服务器安全最好使用sshkey密钥链接,具体我会单独列出一篇文章

2.很多时候由于需要拉取开源项目等等需要安装git
```shell
pacman -S git
```
3.pacman基本命令
```shell
pacman -Syy #同步镜像源

pacman -Syyu #同步镜像源并且更新所有软件

pacman -Ss pkg_name#搜索本地镜像库中有没有软件pkg_name

示例：

pacman -Ss vim#搜索名字为vim的软件

extra/vim 8.1.2268-2 [installed]

    Vi Improved, a highly configurable, improved version of the vi text editor

pacman -S pkg_name #安装名字为pkg_name 的软件

示例：

pacman -S vim#安装vim

pacman -Qs pkg_name#搜索本地安装的软件有没有软件pkg_name

示例：

pacman -Qs vim #查看本地是否有vim

local/vim 8.1.2268-2

    Vi Improved, a highly configurable, improved version of the vi text editor
```
4.pacman特殊设置和aur源

<font color=green>&emsp;&emsp;archlinuxcn源是中国人自己整理的国内常用软件的整理，同时也包含了很多软件的整理，例如打包的wineqq、迅雷以及其他常用软件、无特殊需要服务器不建议使用</font>

&emsp;&emsp;4.1使用方法：在 /etc/pacman.conf 文件末尾添加以下两行：
```shell
[archlinuxcn]

Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```
&emsp;&emsp;4.2安装 archlinuxcn-keyring 包导入 GPG key。
```shell
pacman -Sy archlinuxcn-keyring
```
&emsp;&emsp;4.3该镜像源链接帮助：https://mirrors.tuna.tsinghua.edu.cn/help/archlinuxcn/

<font color=red>aur源是指社区提交未被正式列入官方源的和陈旧的软件包，无特殊需要服务器不建议使用</font>

&emsp;&emsp;4.4由于yaourt失去维护建议使用yay,并且强烈不建议服务器使用aur源
<font color=red>官方源以不再收录yay，如需使用请看新文章 <a href="/posts/2020-01-20">新文章点我</a></font>
```shell
pacman -S yay
```
&emsp;&emsp;yay执行以下命令修改 aururl :
```shell
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
```
其他配置需求可参考本人其他文章

