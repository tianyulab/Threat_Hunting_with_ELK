#!/bin/bash

echo "配置ELK(Logstash)接收来自FileBeat收集的Bro日志"

cd /etc/logstash/conf.d
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Filebeat_conf/Bro_Filebeat_Logstash.conf

echo "启动Logstash服务：systemctl start logstash.service"
# systemctl start logstash.service

