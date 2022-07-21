#!/bin/sh
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

cd $DIR

if [ -z $DOMAIN ];then
    echo "未设置环境变量-DOMAIN"
    exit 2
fi

if [ ! -e "/etc/caddy/Caddyfile" ];then
    WS_PATH="`echo $RANDOM | md5sum | cut -c 3-11`"
    WS_PORT=$(($RANDOM+1234))
    UUID=$(uuidgen)

    if [ -z $EMAIL ];then
        cp -f /conf/caddy/http.Caddyfile /etc/caddy/Caddyfile
    else
        cp -f /conf/caddy/https.Caddyfile /etc/caddy/Caddyfile
    fi
    
    sed -i "s/example.domain/${DOMAIN}/" /etc/caddy/Caddyfile
    sed -i "s/ws_path/${WS_PATH}/" /etc/caddy/Caddyfile
    sed -i "s/1234/${WS_PORT}/" /etc/caddy/Caddyfile
    sed -i "s/your@email.com/${EMAIL}/" /etc/caddy/Caddyfile

    cp -f /conf/v2ray/default_config.json /etc/v2ray/config.json
    sed -i "s/1234/${WS_PORT}/" /etc/v2ray/config.json
    sed -i "s/uuid/${UUID}/" /etc/v2ray/config.json
    sed -i "s/ws_path/${WS_PATH}/" /etc/v2ray/config.json

    echo "====================================="
    echo "V2ray 配置信息"
    echo "地址（address）: ${DOMAIN}"
    echo "端口（port）： 443"
    echo "用户id（UUID）： ${UUID}"
    echo "加密方式（security）： 自适应"
    echo "传输协议（network）： ws"
    echo "伪装类型（type）： none"
    echo "路径（不要落下/）： /${WS_PATH}/"
    echo "底层传输安全： tls"
    echo "====================================="

    cp -f /conf/v2ray/default_client.json /etc/v2ray/client.json
    sed -i "s/hostname-placeholder/${DOMAIN}/" /etc/v2ray/client.json
    sed -i "s/address-placeholder/${DOMAIN}/" /etc/v2ray/client.json
    sed -i "s/uuid-placeholder/${UUID}/" /etc/v2ray/client.json
    sed -i "s/ws_path-placeholder/${WS_PATH}/" /etc/v2ray/client.json

    clientBase64="`cat /etc/v2ray/client.json | base64 -w 0`"
    echo "=========复制以下内容进行导入=========="
    echo "vmess://"$clientBase64
    echo "=========复制以上内容进行导入=========="
fi

start-stop-daemon --start \
	-b -1 /var/log/v2ray.log -2 /var/log/v2ray.log \
	-m -p /run/v2ray.pid \
	--exec /usr/bin/v2ray -- -config /etc/v2ray/config.json

/usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile