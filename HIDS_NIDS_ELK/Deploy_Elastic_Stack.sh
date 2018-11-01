#!/bin/bash

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

# 记录脚本行为（排错目的），sh -x Deploy_Wazuh_server.sh
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# 软件环境：
# CentOS 7.x 
# Elastic Stack 6.4.x

# 1.安装依赖软件包，JRE
curl -Lo jre-8-linux-x64.rpm --header "Cookie: oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jre-8u191-linux-x64.rpm"
rpm -qlp jre-8-linux-x64.rpm > /dev/null 2>&1 && echo "Java package downloaded successfully" || echo "Java package did not download successfully"
yum -y install jre-8-linux-x64.rpm
rm -f jre-8-linux-x64.rpm

# 2.安装elasticsearch、logstash、kibana
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/elastic.repo << EOF
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
#
yum -y install elasticsearch-6.4.2
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
curl "localhost:9200/?pretty"
# Load the Wazuh template for Elasticsearch:
curl https://raw.githubusercontent.com/wazuh/wazuh/3.6/extensions/elasticsearch/wazuh-elastic6-template-alerts.json | curl -XPUT 'http://localhost:9200/_template/wazuh' -H 'Content-Type: application/json' -d @-
yum -y install logstash-6.4.2
# Download the Wazuh configuration file for Logstash:
curl -so /etc/logstash/conf.d/01-wazuh.conf https://raw.githubusercontent.com/wazuh/wazuh/3.6/extensions/logstash/01-wazuh-remote.conf
systemctl daemon-reload
systemctl enable logstash.service
systemctl start logstash.service
yum -y install kibana-6.4.2
export NODE_OPTIONS="--max-old-space-size=3072"
sudo -u kibana /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.6.1_6.4.2.zip
# 参考：https://github.com/wazuh/wazuh-kibana-app#installation
# /etc/kibana/kibana.yml # 可选
# server.host: "0.0.0.0"
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service

# 3.验证
curl "localhost:9200/?pretty"
systemctl status logstash.service
systemctl status kibana.service

