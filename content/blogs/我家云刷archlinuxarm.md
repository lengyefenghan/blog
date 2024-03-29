---
title: "我家云刷archlinuxarm"
date: 2022-10-29T09:37:32+08:00
draft: true
---

# 我家云刷archlinuxarm
前几天咸鱼100收了个我家云,换了好几个固件都不舒服,最后决定自己弄个archlinuxarm的固件

## 原始固件
采用乘风大佬的纯净固件内核
可惜乘风大佬博客网站无法访问了无法知道修改了什么
地址:阿里云盘

## 新增修改
使用archlinuxarm 2002-08-10的tar.gz包
文件:阿里云盘

## 参考博客
https://blog.kangkang.org/post/474.html
页面备份:

# 制作固件
## 整理文件
1. 重命名armbian固件为base.img
2. 重命名alinuxarm包为aarm.tar.gz
3. 查看固件信息
    ``` sh 
    fdisk -l base.img 
    Disk base.img：1.71 GiB，1837105152 字节，3588096 个扇区单元：扇区 / 1 * 512 = 512 字节扇区大小(逻辑/物理)：512 字节 / 512 字节I/O 大小(最小/最佳)：512 字节 / 512 字节磁盘标签类型：dos
    磁盘标识符：0xb1d76d5f
    设备       启动  起点    末尾    扇区  大小 Id 类型
    base.img    1   32768 3588095 3555328  1.7G 83 Linux
    ```
4. kangkang: 注意到没有这个分区开始位置比较靠后，在 32768 扇区位置， 32768 * 512 = 16M ，也就是说这个镜像前面 16M 不在分区里面，应该都是 bootloader 一类的。我们把它 mount 上看看啥样子

## 准备修改
1. 查看可挂载区域并挂载
    ```sh
        sudo losetup -f
            /dev/loop0
        sudo losetup -o 16777216 -f base.img
        sudo losetup -a
            /dev/loop0: [2065]:11562563 (/home/lengyefenghan/Downloads/linuxarm/base.img)，偏移 16777216
        sudo mount /dev/loop0 /mnt
    ```
2. 查看文件
3. 备份内核固件
   ```sh
   cd /mnt
   tar czf /tmp/armbian.tar.gz boot/ usr/lib/modules usr/lib/firmware
   ```
4. 解压arch
    ```sh
        #切换到root
        sudo su
        mkdir arch
        cd arch
        tar zxvf ../aarch.tar.gz
    ```
6. kangkang的博客中由于centeos体积过大需要扩容 但是arch没这么大体积 所以不需要扩容
7. 拷贝文件
    ``` sh 
        #先删除所有文件
        rm -rf /mnt/*
        cp arch/* /mnt -R
        #清理archlinux的内核 /mnt目录下 root身份
        rm -rf boot usr/lib/modules usr/lib/firmware
        #解压内核 /mnt下执行 root身份
        tar zvf /tmp/armbian.tar.gz
    ```

## 后续修改
1. 根据blkid生成/etc/fstab
    ```sh
    blkid | grep loop
    /dev/loop0: LABEL="armbian_root" UUID="044cf33a-fe22-40c6-9770-f603f3344f46" BLOCK_SIZE="4096" TYPE="ext4"
    ```
2. 修改fstab改为这一行
   ``` fstab
        UUID=044cf33a-fe22-40c6-9770-f603f3344f46 /              ext4    defaults,noatime 0 1
    ```
3. 取消挂载 umount -R /mnt
4. losetup -D

## 根据刷入教程刷入

## 后续 宣告失败