---
title: "archlinux从aur源编译yay"
date: 2020-01-20T10:02:20Z
draft: false
tags: ["archlinux","aur"]

categories: ["Archlinux"]
---

<font color=red>&emsp;&emsp;aur全称Arch User Repository，是为用户而建、由用户主导的 Arch 软件仓库。AUR 中的软件包以软件包生成脚本（PKGBUILD）的形式提供，用户自己通过 makepkg 生成包，再由 pacman 安装。创建 AUR 的初衷是方便用户维护和分享新软件包，并由官方定期从中挑选软件包进入 community 仓库。本文介绍用户访问和使用 AUR 的方法。</font>



&emsp;&emsp;早期在arch的官方源里面包含了aur的管理器，方便安装aur源的软件，但是近期的更新中把aur源的管理器逐渐从官方源移回了aur，也就是需要自己编译安装，这里就举例安装yay，之后使用yay安装软件。



1.安装依赖，包括base-devel和git 
```shell
pacman -S base-devel git
```
2.下载代码
```shell
git clone https://aur.archlinux.org/yay.git
```
3.或者下载快照，并解压
```shell
curl curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz

tar zxvf yay.tar.gz
```
4.使用cd命令进入yay文件夹

5.可选：less 查看PKGBUILD,然后编译安装
```shell
makepkg -si编译不能以root用户运行
```
&emsp;&emsp;过程中包括输入当前用户密码使用sudo命令安装依赖，例如yay安装的依赖就是go，因为yay使用go语言开发

6.使用yay

<font color=red>yay需要在非root用户下运行</font>

&emsp;&emsp;命令参数和pacman基本一样


<font color=green>
注意事项：

&emsp;&emsp;1.aur的PKGBUILD体积较小，建议了解一下，速度慢换aur源也没用，不如自己修改PKGBUILD里面的下载链接

&emsp;&emsp;2.aur源的软件存在风险，不兼容，版本过旧的问题，需要自己去探索和研究

&emsp;&emsp;3.aur里面还包含了很多国产软件包括360浏览器什么的

&emsp;&emsp;4.如果遇到yay版本过老的问题可以参考本人其他有关aur的文章，以时间为准，或者去研究arch的官方wiki

&emsp;&emsp;5.本文的方法也可作为手动编译aur源其他软件的文档，注意仅仅是参考

&emsp;&emsp;6.直接git clone得到的是最新上传的，不一定需要下载快照
</font>
