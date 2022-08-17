#!/bin/bash
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

# // Warna
RED='\033[0;31m'                                                                                          
GREEN='\033[0;32m'                                                                                        
ORANGE='\033[0;33m'
BLUE='\033[0;34m'                                                                                         
PURPLE='\033[0;35m'
CYAN='\033[0;36m'                                                                                         
NC='\033[0;37m'
LIGHT='\033[0;37m'

#Welcome Note
echo -e "============================================="
echo -e " ${green} WELCOME TO JINGGO SCRIPT${NC}"
echo -e "============================================="
sleep 2

#Install Update
echo -e "============================================="
echo -e " ${green} UPDATE && UPGRADE PROCESS${NC}"
echo -e "============================================="
apt -y update 
apt install -y bzip2 gzip coreutils screen curl
sleep 2
clear

# Subdomain Settings
sleep 2
echo -e "============================================="
echo -e "${green} DOMAIN INPUT${NC} "
echo -e "============================================="
sleep 2

# // Add Folder
clear
mkdir -p /etc/jinggovpn/xray
mkdir -p /etc/jinggovpn//tls
mkdir -p /var/log/xray/
mkdir /var/lib/jinggo007;
touch /etc/jinggovpn//xray/uservmess.txt
touch /etc/jinggovpn//xray/uservless.txt
touch /etc/jinggovpn//xray/usertrojan.txt
touch /etc/jinggovpn//xray/userss.txt
clear
echo -e ""
echo -e "${green}MASUKKAN DOMAIN ANDA YANG TELAH DI POINT KE IP ANDA${NC}"
read -rp "    Enter your Domain/Host: " -e host
ip=$(wget -qO- ipv4.icanhazip.com)
host_ip=$(ping "${host}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
if [[ ${host_ip} == "${ip}" ]]; then
    echo -e ""
    echo -e "${green}HOST/DOMAIN MATCHED..INSTALLATION WILL CONTINUE${NC}"
    echo "IP=$host" >> /var/lib/jinggo007/ipvps.conf
    echo "$host" >> /etc/jingovpn/xray/domain
    echo "$host" >> /root/domain
    sleep 2
    clear
else
    echo -e "${green}HOST/DOMAIN NOT MATCHED..INSTALLATION WILL TERMINATED${NC}"
    echo -e ""
    rm -f setup.sh
    exit 1
fi

domain=$(cat /root/domain)
echo "IP=$MYIP" >> /var/lib/jinggo007/ipvps.conf

clear
# // Update
apt-get update -y && apt-get upgrade -y && update-grub -y
clear
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 



# // Install ssh ovpn
wget https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/SSHOVPN/ssh-vpn.sh && chmod +x ssh-vpn.sh && screen -S ssh-vpn ./ssh-vpn.sh

# // Instal Xray
wget https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/ins-xray.sh && chmod +x ins-xray.sh && screen -S xray ./ins-xray.sh



#install resolv
apt install resolvconf
systemctl start resolvconf.service
systemctl enable resolvconf.service
echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/head
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
systemctl restart resolvconf.service

cd

rm -f /root/ssh-vpn.sh
rm -f /root/set-br.sh
rm -f /root/ins-xray.sh
rm -f /root/ohp.sh
rm -f /root/domain


restart
history -c
clear

# // Info
sleep 2
clear
echo " "
echo "INSTALLATION COMPLETE!!"
echo " "
echo "====================== JINGGO AUTOSCRIPT MULTIPORT =======================" | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200"  | tee -a log-install.txt
echo "   - OPENVPN OHP             : 8000"  | tee -a log-install.txt
echo "   - Stunnel4                : 444, 777"  | tee -a log-install.txt
echo "   - Dropbear                : 109, 143"  | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8080 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Badvpn                  : 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 89"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   - XRAY VLESS WS TLS       : 443"  | tee -a log-install.txt
echo "   - XRAY VMESS WS TLS       : 443"  | tee -a log-install.txt
echo "   - XRAY TROJAN WS TLS      : 443"  | tee -a log-install.txt
echo "   - XRAY VLESS GRPC         : 443"  | tee -a log-install.txt
echo "   - XRAY VMESS GRPC         : 443"  | tee -a log-install.txt
echo "   - XRAY TROJAN GRPC        : 443"  | tee -a log-install.txt
echo "   - XRAY SS GRPC            : 443"  | tee -a log-install.txt
echo "   - XRAY SS WS TLS          : 443"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   - XRAY TROJAN WS NTLS     : 80"  | tee -a log-install.txt
echo "   - XRAY VLESS WS NTLS      : 80"  | tee -a log-install.txt
echo "   - XRAY VMESS WS NTLS      : 80"  | tee -a log-install.txt
echo "   - XRAY SS WS NTLS         : 80"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                 : Asia/Kuala_Lumpur (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban                 : [ON]"  | tee -a log-install.txt
echo "   - DDOS Dflate              : [ON]"  | tee -a log-install.txt
echo "   - IPtables                 : [ON]"  | tee -a log-install.txt
echo "   - Auto-Remove-Expired      : [ON]"  | tee -a log-install.txt                
echo "   - Auto-Reboot              : [OFF]" | tee -a log-install.txt
echo "   - IPv6                     : [OFF]" | tee -a log-install.txt
echo "   - AutoKill Multi Login User       " | tee -a log-install.txt
echo "   - Auto Delete Expired Account     " | tee -a log-install.txt
echo "   - Fully automatic script          " | tee -a log-install.txt
echo "   - VPS settings                    " | tee -a log-install.txt
echo "   - Admin Control                   " | tee -a log-install.txt
echo "   - Change port                     " | tee -a log-install.txt
echo "   - Restore Data                    " | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo ""
echo "   - Modded by               : JINGGO007"  | tee -a log-install.txt
echo "   - Telegram                : t.me/jinggo007"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "========================== SCRIPT BY JINGGO007 =====================" | tee -a log-install.txt
echo ""

sleep 1

# // Reboot
rm -f /root/.bash_history
rm -f setup.sh
read -n 1 -r -s -p $'Press any key to reboot...\n';reboot

