#!/bin/bash

# 记录脚本行为（排错目的），sh -x Deploy_Kafka_for_Bro.sh
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# 软件环境：
# Ubuntu 16.04
# Elastic Stack 6.4
# Bro 2.5.5
# Kafka 2.12
# librdkafka-0.9.4

# 安装依赖工具
echo "nameserver 9.9.9.9" > /etc/resolv.conf
apt -y install wget curl git

# 1.安装Kafka
# 创建临时目录
mkdir /src && cd /src

# 下载&验证kafka
wget https://archive.apache.org/dist/kafka/1.0.0/kafka_2.12-1.0.0.tgz
wget https://archive.apache.org/dist/kafka/1.0.0/kafka_2.12-1.0.0.tgz.asc
gpg --recv-keys --keyserver keys.gnupg.net 3B417B9B
gpg -v kafka_2.12-1.0.0.tgz.asc

# 安装&启动kafka服务
tar -xf kafka_2.12-1.0.0.tgz
sudo mv kafka_2.12-1.0.0 /opt/kafka
sudo sed -i '/^log.dirs/{s/=.*//;}' /opt/kafka/config/server.properties
sudo sed -i 's/^log.dirs/log.dirs=\/var\/lib\/kafka/' /opt/kafka/config/server.properties
sudo sed -i '$alisteners=PLAINTEXT://BRO所在机器的IP地址:9092' /opt/kafka/config/server.properties 

cat > /etc/systemd/system/kafka.service << EOF
[Unit]
Description=Kafka Service
Wants=network.target
After=zookeeper.target

[Service]
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecReload=on-failure
Restart=always
User=root
Group=root
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF

# 
sudo apt-get -y install zookeeperd
sudo systemctl enable zookeeper 
sudo systemctl start zookeeper
sudo systemctl daemon-reload
sudo systemctl enable kafka 
sudo systemctl start kafka

# 2.安装kafka插件（metron-bro-plugin-kafka）
## 安装librdkafka
apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev
curl -L https://github.com/edenhill/librdkafka/archive/v0.9.4.tar.gz | tar xvz 
cd librdkafka-0.9.4/ 
./configure --enable-sasl 
make 
sudo make install 
## 构建插件
### 先安装Bro 2.5.5
cd /src
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro/Install_Bro_from_source.sh
chmod +x Install_Bro_from_source.sh && ./Install_Bro_from_source.sh

git clone https://github.com/apache/metron-bro-plugin-kafka.git
cd metron-bro-plugin-kafka
./configure --bro-dist=/src/bro-2.5.5/
make 
sudo make install
## 验证
/usr/local/bro/bin/bro -N Apache::Kafka

# 3.配置Bro把日志发送到Kafka

echo "@load /usr/local/bro/lib/bro/plugins/APACHE_KAFKA/scripts/Apache/Kafka/logs-to-kafka.bro" >> /usr/local/bro/share/bro/site/local.bro
echo 'redef Kafka::topic_name = "";' >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::logs_to_send = set(Conn::LOG, HTTP::LOG, DNS::LOG, SMTP::LOG, SSL::LOG, Software::LOG, DHCP::LOG, FTP::LOG, IRC::LOG, Notice::LOG, X509::LOG, SSH::LOG, SNMP::LOG);" >> /usr/local/bro/share/bro/site/local.bro
echo 'redef Kafka::kafka_conf = table(["metadata.broker.list"] = "BRO所在机器的IP地址:9092");' >> /usr/local/bro/share/bro/site/local.bro
echo "redef Kafka::tag_json = T;" >> /usr/local/bro/share/bro/site/local.bro

# 修改Bro接口名称
INAME=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')
sed -i "s/eth0/$INAME/g" /usr/local/bro/etc/node.cfg
/usr/local/bro/bin/broctl deploy

## 验证
systemctl status kafka | grep "Active:.active"
netstat -tunlp  | grep 9092
ls -lh /var/lib/kafka/

# 4.配置Logstash接收Kafka日志
## 先安装Logstash
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro/Install_Logstash.sh
chmod +x Install_Logstash.sh && ./Install_Logstash.sh
systemctl start logstash
systemctl enable logstash
echo "config.reload.automatic: true" | sudo tee -a /etc/logstash/logstash.yml
echo "config.reload.interval: 3s" | sudo tee -a /etc/logstash/logstash.yml
echo "请修改10.42.94.92 --> 为Kafka监听IP"
echo "请修改192.168.8.112 --> 为Elasticsearch监听IP"

## 创建Logstash配置

cat > /etc/logstash/conf.d/bro-conn.conf << EOF
input {
	kafka {
		topics => ["conn"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "conn"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "conn" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-conn-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-dhcp.conf << EOF
input {
	kafka {
		topics => ["dhcp"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "dhcp"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "dhcp" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-dhcp-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-dns.conf << EOF
input {
	kafka {
		topics => ["dns"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "dns"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "dns" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-dns-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-http.conf << EOF
input {
	kafka {
		topics => ["http"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "http"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "http" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-http-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-notice.conf << EOF
input {
	kafka {
		topics => ["notice"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "notice"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "notice" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-notice-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-software.conf << EOF
input {
	kafka {
		topics => ["software"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "software"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "software" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-software-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-ssh.conf << EOF
input {
	kafka {
		topics => ["ssh"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "ssh"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "ssh" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-ssh-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-ssl.conf << EOF
input {
	kafka {
		topics => ["ssl"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "ssl"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "ssl" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-ssl-%{+YYYY.MM.dd}"
		}
	}
}
EOF
#
cat > /etc/logstash/conf.d/bro-x509.conf << EOF
input {
	kafka {
		topics => ["x509"]
		group_id => "bro_logstash"
     		bootstrap_servers => "10.42.94.92:9092"
     		codec => json
     		type => "x509"
     		auto_offset_reset => "earliest"
	}
}

output {
	if [type] == "x509" {
		elasticsearch {
			hosts => ["192.168.8.112:9200"]
			index => "bro-x509-%{+YYYY.MM.dd}"
		}
	}
}
EOF


# For testing on Docker container
# echo "nameserver 9.9.9.9" > /etc/resolv.conf
# apt update && apt -y install vim wget sudo dnsutils ssh curl git net-tools zookeeperd iproute2 iputils-ping
# sudo apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

# /etc/init.d/zookeeper start
# /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties &
# /usr/share/logstash/bin/logstash "--path.settings" "/etc/logstash" &




