#!/bin/bash
clear
red='\e[1;31m'
green='\e[0;32m'
blue='\e[0;34m'
blue_b='\e[0;94m'
NC='\e[0m'

echo -e " "
IPVPS=$(curl -s icanhazip.com)
DOMAIN=$(cat /etc/jinggovpn/xray/domain)
cekxray="$(openssl x509 -dates -noout < /etc/jinggovpn/tls/xray.crt)"                                      
expxray=$(echo "${cekxray}" | grep 'notAfter=' | cut -f2 -d=)


echo -e  "${blue_b}       JINGGOVPN AUTOSCRIPT MULTIPORT"${NC}
echo -e  " "
echo -e  " ${green}IP VPS NUMBER               : $IPVPS${NC}"
echo -e  " ${green}DOMAIN                      : $DOMAIN${NC}"
echo -e  " ${green}OS VERSION                  : `hostnamectl | grep "Operating System" | cut -d ' ' -f5-`"${NC}
echo -e  " ${green}KERNEL VERSION              : `uname -r`${NC}"
echo -e  " ${green}EXP DATE CERT XRAY          : $expxray${NC}"
echo -e  " "
echo -e  " ═════════════════════════════════════════════════════════════════ "
echo -e  " ${green}SERVICE MENU${NC} "                                       
echo -e  " ═════════════════════════════════════════════════════════════════ "
echo -e  " [  1 ] MENU SSH/OVPN" 
echo -e  " [  2 ] MENU XRAY" 
echo -e  " [  3 ] MENU TRIAL" 
echo -e  "  "
echo -e  " ═════════════════════════════════════════════════════════════════ "
echo -e  " ${green}SYSTEM MENU${NC} "       
echo -e  " ═════════════════════════════════════════════════════════════════ "                            
echo -e  " [  4 ] ADD/CHANGE DOMAIN VPS"
echo -e  " [  5 ] CHANGE PORT SERVICE"
echo -e  " [  6 ] CHANGE DNS SERVER"
echo -e  " [  7 ] RENEW XRAY CERTIFICATION"
echo -e  " [  8 ] WEBMIN MENU"
echo -e  " [  9 ] CHECK RAM USAGE"
echo -e  " [ 10 ] REBOOT VPS"
echo -e  " [ 11 ] SPEEDTEST VPS"
echo -e  " [ 12 ] INSTALL BBR"
echo -e  " [ 13 ] CHECK STREAM GEO LOCATION"
echo -e  " [ 14 ] CHECK SERVICE ERROR"
echo -e  " [ 15 ] RESTART ALL SERVICE"
echo -e  " [ 16 ] DISPLAY SYSTEM INFORMATION"
echo -e  "  "
echo -e  " ═════════════════════════════════════════════════════════════════" 
echo -e  " ${green}[  0 ] EXIT MENU${NC}  "
echo -e  " ═════════════════════════════════════════════════════════════════"
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option :  " menu
echo -e "\e[0m"
 case $menu in
   1)
   mssh
   ;;
   2)
   menu-xray
   ;;
   3)
   menu-trial
   ;;  
   4)
   add-host
   ;;
   5)
   change
   ;;
   6)
   mdns
   ;;
   7)
   recert-xray
   ;;
   8)
   wbmn
   ;;
   9)
   ram
   ;;
   10)
   reboot
   ;;
   11)
   speedtest
   ;;
   12)
   bbr
   ;;
   13)
   nf
   ;;
   13)
   nf
   ;;
   14)
   status
   ;;
   15)
   restart-service
   ;;
   16)
   info
   ;;
   0)
   sleep 0.5
   clear
   jinggo
   ;;
   *)
   echo -e "ERROR!! Please Enter an Correct Number"
   sleep 1
   clear
   menu
   ;;
   esac
