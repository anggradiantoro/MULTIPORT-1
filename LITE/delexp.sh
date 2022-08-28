#!/bin/bash

RED='\033[0;31m'                                                                                          
GREEN='\033[0;32m'                                                                                                                                                                                 
NC='\033[0;37m'

#, // Autodel vmess
data=( `cat /usr/local/etc/xray/vmess.txt | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^### $user" "/usr/local/etc/xray/vmess.txt" | cut -d ' ' -f 3)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" = "0" ]]; then
sed -i "/^### $user $exp/,/^},{/d"  /usr/local/etc/xray/config.json
sed -i "/\b$user\b/d" /usr/local/etc/xray/vmess.txt
rm -f /usr/local/etc/xray/xray-$user-tls.json 
rm -f /usr/local/etc/xray/xray-$user-nontls.json 
fi
done

#, // Autodel vless
data=( `cat /usr/local/etc/xray/vless.txt | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^### $user" "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 3)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" = "0" ]]; then
sed -i "/^### $user $exp/,/^},{/d"  /usr/local/etc/xray/config.json
sed -i "/\b$user\b/d" /usr/local/etc/xray/vless.txt
fi
done

#, // Autodel Trojan
data=( `cat /usr/local/etc/xray/xtr.txt | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^### $user" "/usr/local/etc/xray/xtr.txt" | cut -d ' ' -f 3)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" = "0" ]]; then
sed -i "/^### $user $exp/,/^},{/d"  /usr/local/etc/xray/config.json
sed -i "/\b$user\b/d" /usr/local/etc/xray/xtr.txt
fi
done

systemctl restart xray.service
systemctl restart cron
