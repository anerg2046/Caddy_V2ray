# Caddy V2ray SSL TSL Websocket 整合镜像

### 环境需求：
- 一台运行docker的主机
- 一个域名，可以是二级域名，并已解析A记录到你的主机IP
- 一个邮箱地址，用于caddy申请SSL证书（其实随便写一个也行）

### 快速开始：
```
docker run -d \
  --publish=443:443 \
  --env=DOMAIN=v2.mooim.com \
  --env=EMAIL=r.anerg@gmail.com \
  --restart=always \
  --name=caddy_v2ray \
  anerg/v2ray:latest
```
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
vmess://ewogICAgInYiOiAiMiIsCiAgICAicHMiOiAidjIubW9vaW0uY29tIiwKICAgICJhZGQiOiAidjIubW9vaW0uY29tIiwKICAgICJwb3J0IjogIjQ0MyIsCiAgICAiaWQiOiAiYTczNmIxZWYtYTk2ZS00ZjM1LThmNmItNWI3NmEwNTBlMjgyIiwKICAgICJhaWQiOiAiMCIsCiAgICAibmV0IjogIndzIiwKICAgICJ0eXBlIjogIm5vbmUiLAogICAgImhvc3QiOiAidjIubW9vaW0uY29tIiwKICAgICJwYXRoIjogIi84NzY4ZjVmZjkvIiwKICAgICJ0bHMiOiAidGxzIgp9
{"level":"info","ts":1656863534.6378205,"msg":"using provided configuration","config_file":"/etc/caddy/Caddyfile","config_adapter":"caddyfile"}
{"level":"warn","ts":1656863534.6384249,"logger":"caddyfile","msg":"Unnecessary header_up X-Forwarded-For: the reverse proxy's default behavior is to pass headers to the upstream"}
.......
```


### 注意：如果宿主机已有nginx之类的占用443端口

需要修改参数`--publish=8443:443`指定一个未被占用的宿主机端口，然后使用nginx或其他软件反代

`nginx`需要`ssl_preread`支持，具体可参考这篇博文 https://www.jianshu.com/p/70b500c07ccc

### 可用参数

| 参数名 | 是否必须 | 默认值 | 说明
|  ----  | ----  | ---- | ----
| DOMAIN | 是 | 无 | 申请证书的域名，可以是二级域名
| EMAIL | 是 | 无 | 申请证书的邮箱，可以随便写一个符合规则的邮箱

你可以在 https://github.com/v2fly/v2ray-core/releases 这里找到所有v2ray的版本