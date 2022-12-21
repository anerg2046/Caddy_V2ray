# Caddy V2ray SSL TSL Websocket 整合镜像

[![Build Docker Images](https://github.com/anerg2046/Caddy_V2ray/actions/workflows/workflow.yaml/badge.svg)](https://github.com/anerg2046/Caddy_V2ray/actions/workflows/workflow.yaml)

### 环境需求：
- 一台运行docker的主机
- 一个域名，可以是二级域名，并已解析A记录到你的主机IP
- 一个邮箱地址，用于caddy申请SSL证书，如果不填将不会申请证书，且caddy只监听80端口

### 常见操作系统docker安装教程：

参见官方文档
https://docs.docker.com/engine/install/

### 快速开始

可用参数

| 参数名 | 是否必须 | 默认值 | 说明
|  ----  | ----  | ---- | ----
| DOMAIN | 是 | 无 | 申请证书的域名，可以是二级域名
| EMAIL | 否 | 无 | 申请证书的邮箱，如果不填将不会申请证书，且caddy只监听80端口

```
docker run -d \
  --publish=80:80 \
  --publish=443:443 \
  --env=DOMAIN=v2.mooim.com \
  --env=EMAIL=r.anerg@gmail.com \
  --restart=always \
  --name=caddy_v2ray \
  anerg/v2ray:latest
```

> 开放`80`端口是因为zerossl在发证书的时候需要先访问80端口

之后运行命令`docker logs caddy_v2ray`（注意，这里的`caddy_v2ray`要和命令中的`--name`的值一致）

你就能看到类似如下的输出：

```
=====================================
V2ray 配置信息
地址（address）: v2.mooim.com
端口（port）： 443
用户id（UUID）： a736b1ef-a96e-4f35-8f6b-5b76a050e282
加密方式（security）： 自适应
传输协议（network）： ws
伪装类型（type）： none
路径（不要落下/）： /8768f5ff9/
底层传输安全： tls
=====================================
=========复制以下内容进行导入==========
vmess://ewogICAgInYiOiAiMiIsCiAgICAicHMiOiAidjIubW9vaW0uY29tIiwKICAgICJhZGQiOiAidjIubW9vaW0uY29tIiwKICAgICJwb3J0IjogIjQ0MyIsCiAgICAiaWQiOiAiYTczNmIxZWYtYTk2ZS00ZjM1LThmNmItNWI3NmEwNTBlMjgyIiwKICAgICJhaWQiOiAiMCIsCiAgICAibmV0IjogIndzIiwKICAgICJ0eXBlIjogIm5vbmUiLAogICAgImhvc3QiOiAidjIubW9vaW0uY29tIiwKICAgICJwYXRoIjogIi84NzY4ZjVmZjkvIiwKICAgICJ0bHMiOiAidGxzIgp9
=========复制以上内容进行导入==========
{"level":"info","ts":1656863534.6378205,"msg":"using provided configuration","config_file":"/etc/caddy/Caddyfile","config_adapter":"caddyfile"}
{"level":"warn","ts":1656863534.6384249,"logger":"caddyfile","msg":"Unnecessary header_up X-Forwarded-For: the reverse proxy's default behavior is to pass headers to the upstream"}
.......
```

### 高级使用

如果不想每次更新v2ray版本以后都要从新配置v2ray客户端，那么需要映射出`v2ray`和`caddy`的配置目录到宿主机，同时，证书在一定时间内不能申请多次，所以最好把证书也映射出来，命令如下：

```
docker run -d \
  -v /data/conf/v2ray:/etc/v2ray:rw \
  -v /data/conf/caddy:/etc/caddy:rw \
  -v /data/ssl:/data/caddy/certificates:rw \
  -p 80:80 \
  -p 443:443 \
  -e DOMAIN=v2.mooim.com \
  -e EMAIL=r.anerg@gmail.com \
  --restart=always \
  --name=caddy_v2ray \
  --net=work-net \
  anerg/v2ray:latest
```

这里的`/data/conf/v2ray`和`/data/conf/caddy`你可以自定义，如果报错，就手动创建这俩目录

`--net`可以指定已有的docker网络

### 当有其他代理软件存在的时候

比如你有已经运行的`nginx-proxy`或者`traefik`之类的，那么不设置环境变量`EMAIL`即可，以下是配合`traefik`的例子

```
version: '3'

networks:
  work-net:
    external: true

services:
  caddy_v2ray:
    image: anerg/v2ray
    container_name: caddy_v2ray
    restart: always
    volumes:
      - v2ray:/etc/v2ray:rw
      - caddy:/etc/caddy:rw
    networks:
      - work-net
    environment:
      - "DOMAIN=${V2RAY_DOMAIN:-v2.mooim.com}"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.v2ray.rule=Host(`${V2RAY_DOMAIN:-v2.mooim.com}`)"
      - "traefik.http.routers.v2ray.tls=true"
      - "traefik.http.routers.v2ray.tls.certresolver=leresolver"
      - "traefik.http.routers.v2ray.entrypoints=websecure"
      - "traefik.http.routers.v2ray.service=v2ray"
      - "traefik.http.services.v2ray.loadbalancer.server.port=80"

volumes:
  v2ray:
    name: v2ray_v2ray
  caddy:
    name: v2ray_caddy
```


### 如何更新

先停止并删除镜像文件
```
docker stop caddy_v2ray
docker rm caddy_v2ray
docker rmi anerg/v2ray
```
然后再从新启动即可

### 相关
[JustHost.ru](https://justhost.ru/?ref=69692) 北方联通推荐使用，价格便宜不限量

[CloudCone](https://app.cloudcone.com/?ref=7690) 经常有活动，价格很合适

> 如果开出的ip不能访问，提交一个ticket，让给一个国内可访问ip即可，好像是几块钱rmb

你可以在 https://github.com/v2fly/v2ray-core/releases 这里找到所有v2ray的版本
