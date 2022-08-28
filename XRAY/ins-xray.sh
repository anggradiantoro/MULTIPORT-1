#!/bin/bash
#
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
# ==================================================

# // Install 
domain=$(cat /etc/jinggovpn/xray/domain)
apt-get install netfilter-persistent -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chronyd && systemctl restart chronyd
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Kuala_Lumpur
chronyc sourcestats -v
chronyc tracking -v
ufw disable
date

# // Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 1.5.8


# // Restart & Add File
systemctl daemon-reload
systemctl stop xray
systemctl start xray
systemctl enable xray.service

# // Uuid Service
uuid=$(cat /proc/sys/kernel/random/uuid)

# // Json File
echo '
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
      {
      "port": 14017,
      "protocol": "vless",
      "settings": {
        "clients":  [
          {
            "id": "$uuid",
            "flow": "xtls-rprx-direct"
#vxtls
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 60000,
            "alpn": "",
            "xver": 1
          },
          {
            "dest": 60001,
            "alpn": "h2",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "minVersion": "1.2",
          }
    },
   {
     "listen": "127.0.0.1",
     "port": "14016",
     "protocol": "vless",
      "settings": {
          "decryption":"none",
            "clients": [
               {
                 "id": "$uuid"                 
#vless
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vless"
          }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "23456",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "$uuid",
                 "alterId": 0
#vmess
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vmess"
          }
        }
     },
    {
      "listen": "127.0.0.1",
      "port": "25432",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",		
           "clients": [
              {
                 "password": "$uuid"
#trojanws
              }
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": {
               "path": "/trojan-ws"
            }
         }
     },
    {
         "listen": "127.0.0.1",
        "port": "30300",
        "protocol": "shadowsocks",
        "settings": {
           "clients": [
           {
           "method": "aes-128-gcm",
          "password": "$uuid"
#ssws
           }
          ],
          "network": "tcp,udp"
       },
       "streamSettings":{
          "network": "ws",
             "wsSettings": {
               "path": "/ss-ws"
           }
        }
     },	
      {
        "listen": "127.0.0.1",
     "port": "24456",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "$uuid"
#vlessgrpc
             }
          ]            
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": {
                "serviceName": "vless-grpc"
           }
        }
     },
     {
      "listen": "127.0.0.1",
     "port": "31234",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "$uuid",
                 "alterId": 0
#vmessgrpc
             }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": {
                "serviceName": "vmess-grpc"
          }
        }
     },
     {
        "listen": "127.0.0.1",
     "port": "33456",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               {
                 "password": "$uuid"
#trojangrpc
               }
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": {
               "serviceName": "trojan-grpc"
         }
      }
  },
   {
    "listen": "127.0.0.1",
    "port": "30310",
    "protocol": "shadowsocks",
    "settings": {
        "clients": [
          {
             "method": "aes-128-gcm",
             "password": "$uuid"
#ssgrpc
           }
         ],
           "network": "tcp,udp"
      },
    "streamSettings":{
     "network": "grpc",
        "grpcSettings": {
           "serviceName": "ss-grpc"
          }
       }
    }	
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}

' > /usr/local/etc/xray/config.json

sleep 1

# // Iptable xray
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 14016 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 10085 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 23456 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 25432 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 30300 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 24456 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31234 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 33456 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 30310 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 87654 -j ACCEPT

# // xray
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 14016 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 10085 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 23456 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 25432 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 30300 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 24456 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31234 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 33456 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 30310 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 87654 -j ACCEPT


iptables-save >/etc/iptables.rules.v4
netfilter-persistent save
netfilter-persistent reload

# // Starting
systemctl daemon-reload
systemctl restart xray
systemctl enable xray
systemctl restart xray.service
systemctl enable xray.service

# // Download
cd /usr/local/bin
wget -O trialxray "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/trialxray.sh"

wget -O addvless "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/addvless.sh"
wget -O cekvless "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/cekvless.sh"
wget -O delvless "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/delvless.sh"
wget -O renewvless "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/renewvless.sh"
wget -O trialvless "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/trialvless.sh"

wget -O addvmess "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/addvmess.sh"
wget -O cekvmess "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/cekvmess.sh"
wget -O delvmess "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/delvmess.sh"
wget -O renewvmess "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/renewvmess.sh"
wget -O trialvmess "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/trialvmess.sh"

wget -O addtrojan "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/addtrojan.sh"
wget -O cektrojan "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/cektrojan.sh"
wget -O deltrojan "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/deltrojan.sh"
wget -O renewtrojan "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/renewtrojan.sh"
wget -O trialtrojan "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/trialtrojan.sh"

# // Menu Xray
wget -O mxraynew "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/mxraynew.sh"
wget -O mxraytrial "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/mxraytrial.sh"
wget -O mxrayextend "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/mxrayextend.sh"
wget -O mxraycek "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/mxraycek.sh"
wget -O mxraydel "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/mxraydel.sh"

chmod +x trialxray
chmod +x addvless
chmod +x delvless
chmod +x cekvless
chmod +x renewvless
chmod +x trialvless
chmod +x addvmess
chmod +x delvmess
chmod +x cekvmess
chmod +x renewvmess
chmod +x trialvmess
chmod +x addtrojan
chmod +x deltrojan
chmod +x cektrojan
chmod +x renewtrojan
chmod +x trialtrojan
chmod +x mxraynew
chmod +x mxraytrial
chmod +x mxrayextend
chmod +x mxraycek
chmod +x mxraydel
cd


rm -f ins-xray.sh
clear
echo -e " ${RED}XRAY INSTALL DONE ${NC}"
sleep 2
clear

cp /root/domain /etc/xray
systemctl daemon-reload
systemctl restart nginx
systemctl restart xray
