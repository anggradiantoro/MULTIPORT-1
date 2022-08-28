#!/bin/bash
clear
echo -e "MASUKKAN DOMAIN BARU ATAU TEKAN CTL C UTK EXIT"
echo -e ""
read -p "HOSTANME/DOMAIN: " host
rm -f /var/lib/premium-script/ipvps.conf
rm -f /etc/xray/domain
mkdir /etc/xray
mkdir /var/lib/premium-script/ipvps.conf;
echo "IP=$host" >> /var/lib/premium-script/ipvps.conf
echo "$host" >> /etc/xray/domain
clear
#recert
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
sleep 1
echo -e "============================================="
echo -e " ${green} RECERT XRAY${NC}"
echo -e "============================================="
sleep 1
echo start
sleep 0.5
domain=$(cat /etc/jinggovpn/xray/domain)
systemctl stop xray
systemctl stop xray.service
systemctl stop nginx
sudo kill -9 $(sudo lsof -t -i:80)
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc
systemctl daemon-reload
systemctl restart xray
systemctl restart xray.service
systemctl start nginx
echo Done
sleep 0.5
clear
echo -e "============================================="
echo -e " ${green} PERTUKARAN DOMAIN SELESAI${NC}"
echo -e "============================================="
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu