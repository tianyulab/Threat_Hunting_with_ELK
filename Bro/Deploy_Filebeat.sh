#!/bin/bash

echo "Ubuntu 16.04 配置FileBeat收集Bro日志"

wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Filebeat_conf/Bro_filebeat.yml -O /etc/filebeat/filebeat.yml

echo "执行以下命令，修改8.8.8.8为ELK's Logstash的IP sed -i 's/8.8.8.8/ELK logstash IP/g' Bro_Filebeat_Logstash.conf /etc/filebeat/filebeat.yml"
echo "使用以下命令启动FileBeat服务：service filebeat start"
# service filebeat start

