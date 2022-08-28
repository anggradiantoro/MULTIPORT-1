#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ifconfig.me/ip);
echo "Checking VPS"
clear
vm="$(cat ~/log-install.txt | grep -w "XRAY VMESS NON TLS" | cut -d: -f2|sed 's/ //g')"
vl="$(cat ~/log-install.txt | grep -w "XRAY VLESS NON TLS" | cut -d: -f2|sed 's/ //g')"
echo -e "======================================"
echo -e "      Change Port XRAY Vmess"
echo -e ""
echo -e "     [ 1 ]  XRAY VMESS NON TLS $vm"
echo -e "     [ 2 ]  XRAY VLESS NON TLS $vl"
echo -e "======================================"
echo -e "     [ 0 ]  Exit"
echo -e "======================================"
echo -e ""
read -p "     Select From Options [1-3 or 0] :  " prot
echo -e ""
case $prot in
1)
read -p "XRAY VMESS NON TLS: " vm1
if [ -z $vm1 ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $vm1)
if [[ -z $cek ]]; then
sed -i "s/$vm/$vm1/g" /usr/local/etc/xray/none.json
sed -i "s/- XRAY VMESS NON TLS      : $vm/- XRAY VMESS NON TLS      : $vm1/g" /root/log-install.txt
iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $vm -j ACCEPT
iptables -D INPUT -m state --state NEW -m udp -p udp --dport $vm -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $vm1 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport $vm1 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null
netfilter-persistent reload > /dev/null
systemctl stop xray@none > /dev/null
systemctl enable xray@none > /dev/null
systemctl start xray@none > /dev/null
systemctl restart xray@none > /dev/null
echo -e "\e[032;1mPort $vm1 modified successfully\e[0m"
else
echo "Port $vm1 is used"
fi
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
;;
2)
echo "Input Only 2 Character (eg : 69)"
read -p "New Port XRAY VLESS NON TLS: " vl1
if [ -z $vl1 ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $vl1)
if [[ -z $cek ]]; then
sed -i "s/$vl/$vl1/g" /usr/local/etc/xray/none.json
sed -i "s/- XRAY VLESS NON TLS      : $vl/- XRAY VLESS NON TLS      : $vl1/g" /root/log-install.txt
iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $vl -j ACCEPT
iptables -D INPUT -m state --state NEW -m udp -p udp --dport $vl -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $vl1 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport $vl1 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null
netfilter-persistent reload > /dev/null
systemctl stop xray@none > /dev/null
systemctl enable xray@none > /dev/null
systemctl start xray@none > /dev/null
systemctl restart xray@none > /dev/null
echo -e "\e[032;1mPort $vl1 modified successfully\e[0m"
else
echo "Port $vl1 is used"
fi
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
;;
0)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
