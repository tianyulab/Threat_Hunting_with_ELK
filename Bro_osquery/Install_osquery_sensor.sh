#!/bin/bash
set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately
# 如果sha256sum检查失败，脚本退出

# 运行:sh -x $0 "Bro IP"

# 记录脚本行为（排错目的）
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# Ubuntu 16.04

wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_osquery/osquery_sensor.deb
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_osquery/osquery_sensor.deb.sha256sum
sha256sum -c osquery_sensor.deb.sha256sum
dpkg -i osquery_sensor.deb
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_osquery/osquery.bro.example.conf -O /etc/osquery/osquery.conf

# 4.配置&启动
# export bro_ip=`ip route get 1 | awk '{print $NF;exit}'` # 替换为：Bro IP
export bro_ip="$1"
sudo sed -i -e '/"bro_ip":/s/.*/"bro_ip": "'"$bro_ip"'",/' /etc/osquery/osquery.conf

sudo osqueryctl config-check
# sudo osqueryctl start
# /usr/bin/osqueryd --config_path=/etc/osquery/osquery.conf --pidfile=/var/run/osqueryd.pidfile

# systemd
sudo systemctl enable osqueryd
sudo systemctl start osqueryd

