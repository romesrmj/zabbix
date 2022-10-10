#!/bin/bash

apt update
apt install -y ruby screen figlet toilet cowsay lolcat boxes  > /dev/null 2>&1
toilet -w 100 -f smmono9 Zabbix deploy services | lolcat
toilet -w 82 -f mini Iniciando... | lolcat
gem install apt-spy2
# apt-spy2 fix --commit
cd /tmp 
rm *deb* > /dev/null 2>&1
apt update
apt upgrade -y
apt install -y linux-headers-generic build-essential module-assistant software-properties-common curl pv python3-pip vim -y  > /dev/null 2>&1

wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
apt update
apt install zabbix-server-mysql zabbix-frontend-php  zabbix-agent -y
apt instll zabbix-sql-scripts zabbix-apache-conf  -y

clear
toilet -w 82 -f mini Zabbix deploy | lolcat
toilet -w 100 -f smmono9 deploy by romes morais | lolcat
rm /tmp/finish
apt install -y mysql-server mysql-client
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent 
apt install -y locales   > /dev/null 2>&1
locale-gen pt_BR.UTF-8 
m-a prepare 
# dpkg-reconfigure locales
update-locale LANG=pt_BR.UTF-8 

apt install -y snmp snmpd     > /dev/null 2>&1
apt install -y snmp-mibs-downloader  
mkdir -p $HOME/.snmp

apt install -y lsb-release gnupg 
wget -O - https://repo.nperf.com/apt/conf/nperf-server.gpg.key | apt-key add - &&\
echo "deb [arch=amd64] http://repo.nperf.com/apt $(lsb_release -sc) main non-free" >> /etc/apt/sources.list.d/nperf.list &&\
apt-get update &&\
apt install -y nperf-server

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

export DEBIAN_FRONTEND=noninteractive

mysql -uroot --password="" -e "create database zabbix character set utf8mb4 collate utf8mb4_bin"; 
mysql -uroot --password="" -e "CREATE USER 'zabbix'@'localhost'";
mysql -uroot --password="" -e "GRANT ALL ON zabbix.* TO 'zabbix'@'localhost'";

mysql -uroot --password="" -e "set global log_bin_trust_function_creators = 1";
mysql -uroot --password="" -e "SELECT host, user FROM mysql.user";
mysql -uroot --password="" -e "SHOW GRANTS FOR 'zabbix'@'localhost'";

figlet -w 100 -f smmono9 "CRIANDO BANCO DE DADOS!" | lolcat
figlet -w 100 -f smmono9 "AGUARDE!"  | lolcat

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | pv --progress --size  `gzip -l /usr/share/zabbix-sql-scripts/mysql/server.sql.gz  | sed -n 2p | awk '{print $2}'` | mysql --default-character-set=utf8mb4 -uroot --password="" zabbix
mysql -uroot --password="" -e "set global log_bin_trust_function_creators = 0";

apt install php-mysql
a2enconf zabbix-frontend-php 
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2


> /var/www/html/index.html 
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/g' /etc/apache2/conf-enabled/zabbix.conf

sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_8.5.9_amd64.deb
sudo dpkg -i grafana_8.5.9_amd64.deb


systemctl restart zabbix-server zabbix-agent apache2 grafana-server

grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins update alexanderzobnin-zabbix-app
figlet -w 100 -f smmono9 "CRIANDO SERVIDOR DE LOGS!" | lolcat

apt install -y npm  
npm install pm2 -g  > /dev/null 2>&1
npm install -g log.io  > /dev/null 2>&1
npm install -g log.io-file-input  > /dev/null 2>&1
mkdir -p ~/.log.io/inputs/  > /dev/null 2>&1
touch ~/.log.io/inputs/file.json  > /dev/null 2>&1
touch ~/.log.io/server.json  > /dev/null 2>&1

cat <<'EOF' > ~/.log.io/inputs/file.json
{
  "messageServer": {
    "host": "127.0.0.1",
    "port": 6689
  },
  "inputs": [
    {
      "source": "Linux",
      "stream": "Zabbix Server",
      "config": {
        "path": "/var/log/zabbix/zabbix_server.log"
      }
    },
    {
      "source": "Linux",
      "stream": "Zabbix Agent",
      "config": {
        "path": "/var/log/zabbix/zabbix_agentd.log"
      }
    }
  ]
}
EOF

cat <<'EOF' > ~/.log.io/server.json
{
  "messageServer": {
    "port": 6689,
    "host": "127.0.0.1"
  },
  "httpServer": {
    "port": 6688,
    "host": "0.0.0.0"
  },
  "debug": false,
  "basicAuth": {
    "realm": "abc123xyz",
    "users": {
      "aluno": "logs"
    }
  }
}
EOF


pm2 start log.io-server  > /dev/null 2>&1
pm2 start log.io-file-input  > /dev/null 2>&1
iptables -A INPUT -p tcp -s localhost --dport 3306 -j ACCEPT 
iptables -A INPUT -p tcp --dport 3306 -j DROP 


iptables-save | grep 3306
systemctl status mysql | grep Active
systemctl status zabbix-server | grep Active
systemctl status zabbix-agent | grep Active
systemctl status grafana-server | grep Active
figlet -w 100 -f smmono9 "INSTALANDO ACERVO DE MIBs!" | lolcat
cd /usr/share/snmp/mibs
git clone https://github.com/arturbrasil/vendors.git

#for i in `ls -d /usr/share/snmp/mibs/vendors/*/`; do
# echo "mibdirs +$i" > $HOME/.snmp/snmp.conf
# export MIBDIRS=$MIBDIRS:$i
#done

clear
cd /tmp
wget https://raw.githubusercontent.com/arturbrasil/curriculo/gh-pages/zabbix-datasource

for i in /tmp/zabbix-datasource ; do \
    curl -X "POST" "http://127.0.0.1:3000/api/datasources" \
    -H "Content-Type: application/json" \
    --user admin:admin \
    --data-binary @$i
done

grafana_host="http://localhost:3000"
grafana_cred="admin:admin"
grafana_datasource="zabbix"
apt install -y parallel jq curl httpie nmap ncat dnsutils unzip snmp-mibs-downloader htop speedtest-cli iotop nmap silversearcher-ag ngrep -y   > /dev/null 2>&1
snap install gotop
wget https://raw.githubusercontent.com/arturbrasil/curriculo/gh-pages/dash-redes-sociais.json

cat dash-redes-sociais.json | jq '. * {overwrite: true, dashboard: {id: null}}' | curl -s -k -u "$grafana_cred" -XPOST -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    $grafana_host/api/dashboards/import  -d  @- ;


#FIX CACHESIZE
#sed s/'# CacheSize=8M'/'CacheSize=16M'/g -i /etc/zabbix/zabbix_server.conf
systemctl enable zabbix-server zabbix-agent apache2 grafana-server
systemctl restart zabbix-server zabbix-agent apache2 grafana-server
cat <<'EOF' >> ~/.bashrc
shopt -s histappend
HISTFILESIZE=1000000
HISTSIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='history'
HISTTIMEFORMAT='%F %T '
shopt -s cmdhist
PROMPT_COMMAND='history -a'

alias getip="ip a | grep -oP '(?<=inet |addr:)(?:\d+\.){3}\d+' | grep -v 127.0.0.1"
alias testdns="parallel -j0 --tag dig @{}  ::: 208.67.222.222 208.67.220.220 198.153.192.1 198.153.194.1 156.154.70.1 156.154.71.1 8.8.8.8 8.8.4.4 | grep Query | sort -nk5"
alias fixmibs=export MIBDIRS=`ls  -d /usr/share/snmp/mibs/vendors/*/ |  xargs | tr ' ' ':'` 
export MIBDIRS=`ls  -d /usr/share/snmp/mibs/vendors/*/ |  xargs | tr ' ' ':'` 
ls  -d /usr/share/snmp/mibs/vendors/*/ | xargs -n1 echo mibdirs +  >> /etc/snmp/snmp.conf
#echo "mibs +ALL" >> /etc/snmp/snmp.conf

EOF
. ~/.bashrc 
alias fixmibs="MIBDIRS=`ls  -d /usr/share/snmp/mibs/*/*/| xargs | tr ' ' ':'`"
systemctl enable zabbix-server zabbix-agent apache2 
systemctl enable grafana-server
touch /tmp/finish 
ip=`ip a | grep -oP '(?<=inet |addr:)(?:\d+\.){3}\d+' | grep -v 127.0.0.1`
clear
echo -e "\n\tZabbix: http://$ip/zabbix \tUsuário: Admin - Senha: zabbix \n\tGrafana: http://$ip:3000 \tUsuário: admin - Senha: admin \n\tLogs: http://$ip:6688 \tUsuário: aluno - Senha: logs" | boxes -d spring -a hc -p h8 |lolcat  
cowsay -f tux "No wizard do zabbix, clique em avançar em todas etapas sem alterar nada, nem mesmo as informações do MYSQL!" | lolcat
#lvresize -t -v -l +100%FREE /dev/mapper/ubuntu–vg-ubuntu–lv
#lvresize -v -l +100%FREE /dev/mapper/ubuntu–vg-ubuntu–lv
#resize2fs -p /dev/mapper/ubuntu–vg-ubuntu–lv
toilet -w 100 -f mini FIM. | lolcat