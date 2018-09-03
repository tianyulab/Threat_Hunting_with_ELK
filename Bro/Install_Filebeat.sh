#!/bin/bash

echo "Ubuntu 16.04安装FileBeat"

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get -y install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get -y install filebeat
sudo update-rc.d filebeat defaults 95 10

echo "使用以下命令启动FileBeat服务：service filebeat start"

# For usage,See https://github.com/tianyulab/Threat_Hunting_with_ELK/blob/master/Bro/FileBeat101.md
# 参考：https://www.elastic.co/guide/en/beats/filebeat/current/setup-repositories.html

