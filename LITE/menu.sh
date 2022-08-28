#!/bin/bash
clear
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
blue_b='\e[0;94m'
NC='\e[0m'

echo -e " "
IPVPS=$(curl -s icanhazip.com)
DOMAIN=$(cat /etc/xray/domain)
cekxray="$(openssl x509 -dates -noout < /usr/local/etc/xray/xray.crt)"                                      
expxray=$(echo "${cekxray}" | grep 'notAfter=' | cut -f2 -d=)



echo -e  " "
echo -e  "  ${blue_b}IP VPS NUMBER                    : $IPVPS${NC}"
echo -e  "  ${blue_b}DOMAIN                           : $DOMAIN${NC}"
echo -e  "  ${blue_b}OS VERSION                       : `hostnamectl | grep "Operating System" | cut -d ' ' -f5-`"${NC}
echo -e  "  ${blue_b}KERNEL VERSION                   : `uname -r`${NC}"
echo -e  "  ${blue_b}EXP DATE CERT XRAY               : $expxray${NC}"
echo -e  " "
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " ${gr}═════════════════════════${NC}" "${blue_b}SSH/OVPN MENU${NC}" "${gr}═════════════════════════${NC}"
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${gr}[ 01 ]${NC} CREATE NEW USER            ${gr}[ 06 ]${NC} LIST USER INFORMATION"
echo -e  " ${gr}[ 02 ]${NC} CREATE TRIAL USER          ${gr}[ 07 ]${NC} DELETE USER EXPIRED"
echo -e  " ${gr}[ 03 ]${NC} EXTEND ACCOUNT ACTIVE      ${gr}[ 08 ]${NC} SET AUTO KILL LOGIN"
echo -e  " ${gr}[ 04 ]${NC} DELETE ACTIVE USER         ${gr}[ 09 ]${NC} DISPLAY USER MULTILOGIN"
echo -e  " ${gr}[ 05 ]${NC} CHECK USER LOGIN"
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${gr}═══════════════════════${NC}" "${blue_b}XRAY MENU${NC}" "${gr}═════════════════════${NC} "       
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC} "     
echo -e  " ${gr}[ 10 ]${NC} CREATE NEW USER            ${gr}[ 14 ]${NC}"" CHECK USER LOGIN"
echo -e  " ${gr}[ 11 ]${NC} CREATE TRIAL USER          ${gr}[ 15 ]${NC}"" DELETE USER EXPIRED"
echo -e  " ${gr}[ 12 ]${NC} EXTEND ACCOUNT ACTIVE      ${gr}[ 16 ]${NC}"" RENEW XRAY CERTIFICATION"
echo -e  " ${gr}[ 13 ]${NC} DELETE ACTIVE USER"
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${gr}═════════════════════════${NC}" "${blue_b}SYSTEM MENU${NC}" "${gr}═══════════════════════════${NC} "       
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${gr}[ 17 ]${NC} ADD/CHANGE DOMAIN VPS      ${gr}[ 24 ]${NC} SPEEDTEST VPS"
echo -e  " ${gr}[ 18 ]${NC} CHANGE PORT SERVICE        ${gr}[ 25 ]${NC} INSTALL BBR"
echo -e  " ${gr}[ 19 ]${NC} CHANGE DNS SERVER          ${gr}[ 26 ]${NC} CHECK STREAM GEO LOCATION"
echo -e  " ${gr}[ 20 ]${NC} RESTART ALL SERVICE        ${gr}[ 27 ]${NC} CHECK SERVICE ERROR"
echo -e  " ${gr}[ 21 ]${NC} WEBMIN MENU                ${gr}[ 28 ]${NC} ENCRYPT SHELL SCRIPT"
echo -e  " ${gr}[ 22 ]${NC} CHECK RAM USAGE            ${gr}[ 29 ]${NC} DISPLAY SYSTEM INFORMATION"
echo -e  " ${gr}[ 23 ]${NC} REBOOT VPS"
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC}" 
echo -e  " ${gr}[  0 ]${NC}" "${blue_b}EXIT MENU${NC}  "
echo -e  " ${gr}═════════════════════════════════════════════════════════════════${NC}"
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option :  " menu
echo -e "\e[0m"
 case $menu in
  1)
  clear ; usernew
  ;;
  2)
  clear ; trial 
  ;;
  3)
  clear ; renew
  ;;
  4)
  clear ; hapus
  ;;
  5)
  clear ; cek
  ;;
  6)
  clear ; member
  ;;
  7)
  clear ; delete
  ;;
  8)
  clear ; autokill
  ;;
  9)
  clear ; ceklim
  ;;
  10)
  clear ; mxraynew
  ;;
  11)
  clear ; mxraytrial
  ;;
  12)
  clear ; mxrayextend
  ;;
  13)
  clear ; mxraydel
  ;; 
  14)
  clear ; mxraycek
  ;;
  15)
  clear ; delexp
  ;;
  16)
  clear ; recert-xray
  ;;    
  17)
  clear ; add-host
  ;;
  18)
  clear ; change
  ;;
  19)
  clear ; mdns
  ;;
  20)
  clear ; restart-service
  ;;
  21)
  clear ; wbmn
  ;;
  22)
  clear ; ram
  ;;
  23)
  clear ; reboot
  ;;
  24)
  clear ; speedtest
  ;;
  25)
  clear ; bbr
  ;;
  26)
  clear ; nf
  ;;
  27)
  clear ; status
  ;;
  28)
  clear ; enc
  ;;
  29)
  clear ; info
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
