#!/bin/bash

echo "Ubuntu 16.04 部署Logstash Bro配置文件"

cd /etc/logstash/conf.d

wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-conn_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-dns_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-files_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-http_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-notice_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-ssh_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-ssl_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-weird_log.conf
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_Logstash_conf/bro-x509_log.conf

# 注意：如ELK和Bro不在同一台服务器上，需要修改配置文件中elasticsearch的值，如： hosts => ["ELK IP:9200"]
# sed -i 's/localhost/ELK IP/g' bro*.conf

echo "启动Logstash服务：systemctl start logstash.service"
systemctl start logstash.service
