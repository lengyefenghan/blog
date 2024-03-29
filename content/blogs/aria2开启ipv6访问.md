---
title: "搭建ariang并开启和websockets安全并且为aria2开启ipv6访问"
date: 2022-07-04T11:50:04+08:00
draft: false
tags: ["Linux","nginx","ipv6","aria2nga","ria2"]
---

## 安装aria2

## 1. 需要安装好aria2不在描述，可以看我其他文章

## 2. 修改配置文件开启websockets(安全) 可选非必需项目
``` conf
#是否启用RPC服务的SSL/TLS加密
rpc-secure=true
#申请的域名crt证书文件路径，自行修改
rpc-certificate=/path/cert.crt
##申请的域名key证书文件路径，自行修改
rpc-private-key=/path/cert.key
```
使用时需要在ariang填写域名密钥，而不能直接使用ip访问

## 3. ipv6支持(nginx反向代理)
考虑到很多人是内网ipv4公网ipv6，都是通过远程访问，这里给出了通过ngixn来支持ipv6访问的方式
nginx添加分流规则
``` conf
stream {
    map $ssl_preread_server_name $backend_name {
        # 这里就是 SNI 识别，将域名映射成一个配置名
        ariang.xxx ariang;
        aria2.xxx aria2;
        # 域名都不匹配情况下的默认值
        default ariang;
        }
        #配置分流的单独文件
        upstream ariang{
                server 127.0.0.1:8443;
        }
        upstream aria2{
                server 127.0.0.1:6800;
        }
        # 监听 443 并开启 ssl_preread
        server {
                listen 443 reuseport;
                listen [::]:443 reuseport;
                proxy_pass  $backend_name;
                ssl_preread on;
        }
}
```
根据上面的配置文件，我们在设置dns解析时需要添加一条解析规则指向aria2的ip由于根据443端口分流，所以不影响cdn是否开启,但是根据这么设置的话需要在aria2ng里面填写端口为443

# ariang
1. 前往[ariang官网](http://ariang.mayswind.net/)下载最新版本，并且安装完成
2. 添加http基础验证
a. 修改nginx配置文件
``` 
server {
    listen 80;
    listen [::]:80;
    server_name ariang.xxx;
#    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 8443      ssl http2;
    listen [::]:8443 ssl http2;
    server_name ariang.xxx;

    # Path to the root of your installation
    root /usr/share/webapps/aria2ng;
    ssl_certificate     cert.pem;
    ssl_certificate_key key.pem;

    location / {
        index index.html;
    }
}
```
c. 重启测试

