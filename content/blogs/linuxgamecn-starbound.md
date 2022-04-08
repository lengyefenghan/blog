---
title: "Linux游戏-星界边境"
date: 2020-07-05T09:26:16+08:00
draft: false
---

## 游戏简介

《星界边境(Starbound)》是一款2D像素点风格，科幻背景的沙盒游戏，游戏在风格上有些类似于《泰拉瑞亚(Terraria)》和《我的世界(minecraft)》。

在《星界边境》，你将扮演一个刚刚从自己的母星中逃离，便在另一个星球坠毁的角色。从此你就开始了自己的冒险生涯，在这个无限的宇宙中探索、发现，挣扎求存。

你从一场浩劫中幸存，你驾驶宇宙飞船逃离了自己的母星，你失去了自己的家园，却拥有了整个宇宙——这个宇宙是你的沙盘，这里的每一颗星球、每一寸土壤、每一棵植被……都是你建设基地并武装自己的素材。当然，这是一个机遇与敌意并存的宇宙，星球的原住民——也许还包括其他更具威胁的外来力量，并不认可你对这 个宇宙的所有权，它们会成为你的敌人……也可能成为一种需要通过特殊途径采集
的资源。

你并非孤立无援，亦无需只身一人对抗整个世界的敌意：你的种族已经将文明的火种托付给你，你继承了全部可用于求生和战斗的科技，你知道如何将自然的恩赐转 化为无法撼动之物与无坚不摧之力;其他幸存者也会加入你的探索与冒险之中，为了生存或是超越生存的其他目标与你携手并肩。

从徒有四壁的陋室一步步发展到遍布精密科技的要塞，你成功地在一颗星球上建立起了自己的基地。你将文明的种子播撒至荒野之中，并浇灌其成长为钢筋混凝土的 丛林或是参天大树。你在危机四伏的地下城中探索熟悉或陌生的文明在这颗星球上留下的遗迹，在获取战利品的同时揭开唯有造物主知晓的秘密。当你对一颗星球的 细节已经了如指掌，将地平线建设成为自己的庭院围墙之时，你也许会感到满足，
也许会感到厌倦，但这并不意味着故事的终结：你一定会离开这颗星球，返回飞 船，在浩瀚的星空中选择另一颗未知的星球作为新的目标，游历全新的风景，从一草一木开始改造另一个世界……在千亿星辰之间谱写属于你的故事。

本文由百度贴吧starbound吧吧主“真Leemoon”供稿-转载自游侠网

## 游戏配置要求

最低配置:
+ 操作系统: Debian Stable or Ubuntu 12.04 LTS or later
+ 处理器: Core 2 Duo
+ 内存: 2 GB RAM
+ 显卡: 256 MB graphics memory and opengl 2.1 compatible gpu
+ 网络: 宽带互联网连接
+ 存储空间: 需要 3 GB 可用空间

推荐配置:
+ 操作系统: Debian Stable or Ubuntu 12.04 LTS or later
+ 处理器: Core i3
+ 内存: 4 GB RAM
+ 显卡: 256 MB graphics memory and opengl 2.1 compatible discrete gpu
+ 网络: 宽带互联网连接
+ 存储空间: 需要 4 GB 可用空间

## 安装步骤

1. 打开网站<a href="https://www.linuxgame.cn/starbound">https://www.linuxgame.cn/starbound</a> 下载游戏
2. 进入到下载的文件，查看下载的文件，例如名字为 starbound_1.3.4.24710_amd64.appimage
``` shell
    [lengyefenghan@lengyefeghan Download]$ : ls
    starbound_1.3.4.24710_amd64.appimage
```
2. 找到下载好的文件,为文件添加可执行权限 
``` shell
    chmod +x starbound_1.3.4.24710_amd64.appimage
```
3. 安装缺少的依赖 libsdl2 
``` shell
    apt install libsdl2 #ubuntu
    pacman -S sdl2 #arch
```

4. 在终端里面运行游戏 
``` shell
    starbound_1.3.4.24710_amd64.appimage
```

## 演示视频



<iframe src="//player.bilibili.com/player.html?aid=626167718&bvid=BV1it4y1975R&cid=209012544&page=1" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true"> </iframe>

<a href="https://www.bilibili.com/video/BV1it4y1975R/">视频地址</a>







