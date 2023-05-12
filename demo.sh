#!/bin/bash
###
 # @Author: Takashi
 # @Date: 2023-04-18 20:07:07
 # @LastEditors: Takashi
 # @LastEditTime: 2023-05-12 19:20:13
 # @Description:
### 

declare -A procs
## 字典
procs["basics"]="_update"
procs["portainer"]="_download_portainer"
#procs["zerotier"]="_download_zerotier"
procs["ddns"]="_download_ddns"
procs["iperf"]="_install_iperf_service"
procs["xui"]="_install_xui"
procs["frps"]="_download_frps"
procs["test_func"]="test_func"
procs["docker"]="_download_docker"

# 执行的顺序
declare proc_table=(
    "basics"
    "docker"
    "portainer"
    "ddns"
    "iperf"
    "xui"
    "frps"
    "test"
)

test_func() {
    echo this is test func
}

DOCKER_INSTALLED=false

_update() {
    apt-get update -y
    apt-get install -y wget gzip curl iperf3 nload net-tools
}

_download_docker() {
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 
    sh /tmp/get-docker.sh
    DOCKER_INSTALLED=true
}

_download_portainer() {
    docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock  portainer/portainer-ce:latest
}

_download_ddns() {
    echo "plz enter your CF API_KEY"
    read API_KEY
    if [ -z "$API_KEY" ]; then
        API_KEY=""
    fi
    echo "plz enter your zone"
    read ZONE
    if [ -z "$ZONE" ]; then
        ZONE=""
    fi
    echo "and subdomain?"
    read SUBDOMAIN
    if [ -z "$SUBDOMAIN" ]; then
        echo "Invalid SUBDOMAIN"
        return
    fi
    docker run -d --name ddns --restart=always -e API_KEY=$API_KEY -e ZONE=$ZONE -e SUBDOMAIN=$SUBDOMAIN oznu/cloudflare-ddns
}

# check_confirm name
check_confirm() {
    echo "do you want to install $1?(y/n)"
    read confirm
#        return $([ "$confirm" = "y" ] || [ "$confirm" = "Y" ])

    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        return 0
    else
        return 1 
    fi
}

_install_iperf_service() {
    cat >/lib/systemd/system/iperf.service <<-EOF
[Unit]
Description=Iperf Service
After=network.target
Wants=network.target
 
[Service]
Type=simple
PIDFile=/var/run/iperf.pid
ExecStart=/usr/bin/iperf3 -s -p 40010
RestartSec=3
Restart=always
LimitNOFILE=1048576
LimitNPROC=512
 
[Install]
WantedBy=multi-user.target
EOF
    systemctl enable iperf
    systemctl restart iperf
}

#    bash <(curl -Ls https://raw.githubusercontent.com/CMinHong/repo/main/init.sh)
#    curl https://raw.githubusercontent.com/CMinHong/repo/main/init.sh | bash

_install_xui() {
    curl curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh | bash
}

_download_frps() {
        ver=$(curl -H 'Cache-Control: no-cache' -s https://api.github.com/repos/fatedier/frp/releases | grep -m1 'tag_name' | cut -d\" -f4)
    if [[ ! $ver ]]; then
        echo
        echo -e " $red获取 FRP 最新版本失败!!!$none"
        echo
        echo -e " 请尝试执行如下命令: $green echo 'nameserver 8.8.8.8' >/etc/resolv.conf $none"
        echo
        echo " 然后再重新运行脚本...."
        echo
        exit 1
    fi
 
    _link="https://github.com/fatedier/frp/releases/download/$ver/frp_${ver:1}_linux_amd64.tar.gz"
 
    if ! wget --no-check-certificate -O "/tmp/frp.tar.gz" $_link; then
        echo
        echo -e "$red 下载 FRP 失败！$none"
        echo
        exit 1
    fi
 
    tar -xf /tmp/frp.tar.gz -C /tmp
    cp /tmp/frp_${ver:1}_linux_amd64/frps /usr/sbin/
    rm -rf /tmp/frp* 
 
    chmod +x /usr/sbin/frps
}

usage="Usage: $0 [-y] [-i packname] [-c] [-h]
Options:
    -y              install all packs.
    -i packname     install pack.
    -c              print support packs.
    -h              display this.
"

print() {
    for name in "${!procs[@]}"
    do
        echo $name
    done
}

install_all_check() {
    for name in "${proc_table[@]}"
    do
        check_confirm $name && ${procs[$name]}
    done
}

install_all() {
    for name in "${proc_table[@]}"
    do
        $[procs[$name]]
    done
}

check_arg() {
    while getopts "y:i:ch" opt; do
        case $opt in
            h)
            echo "$usage" >&2
            exit 0
            ;;
            y)
            install_all
            ;;
            i)
            ${procs[$2]}
            ;;
            c)
            print
            ;;
            \?)
            echo "$usage" >&2
            exit 1
            ;;
        esac
    done
    if [ $# -eq 0 ]; then
        install_all_check
    fi
}

check_arg "$@"
