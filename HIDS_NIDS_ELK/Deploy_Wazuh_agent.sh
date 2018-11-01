#!/bin/bash

echo -e "请在Wazuh Manager上执行以下命令，再执行本脚本。\n"
echo "注册Wazuh Agent"
echo "1.Wazuh Manager 上执行："
echo "# openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -keyout /var/ossec/etc/sslmanager.key -out /var/ossec/etc/sslmanager.cert"
echo -e "# /var/ossec/bin/ossec-authd -i\n"

echo -e "Sleeping 60s\n"
sleep 60

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

# 记录脚本行为（排错目的），sh -x Deploy_Wazuh_agent.sh
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# 软件环境：
# Ubuntu 16.04
# Wazuh 3.6.x

apt-get -y install curl apt-transport-https lsb-release
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get -y install wazuh-agent

# 注册Wazuh Agent
# 1.Wazuh Manager 上执行：
# openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -keyout /var/ossec/etc/sslmanager.key -out /var/ossec/etc/sslmanager.cert
# /var/ossec/bin/ossec-authd -i

# 2.Wazuh Agent 上执行：
sed -i "s/MANAGER_IP/8.8.8.8/"  /var/ossec/etc/ossec.conf
/var/ossec/bin/agent-auth -m 8.8.8.8
systemctl restart wazuh-agent

# 验证
systemctl status wazuh-agent
