#!/bin/sh
###
 # @Author: Takashi
 # @Date: 2023-04-18 20:07:07
 # @LastEditors: Takashi
 # @LastEditTime: 2023-04-18 20:07:12
 # @Description: file content
### 

_update() {
    apt-get update -y
	apt-get install -y wget gzip curl iperf3 nload net-tools
}

_download_docker() {
	curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 
	sh /tmp/get-docker.sh
    docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock  portainer/portainer-ce:latest
}

install() {
    _update
    _download_docker
}

pause
install