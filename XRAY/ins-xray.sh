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


 INSTALL XRAY
wget -c -P /etc/jinggovpn/xray/ "https://github.com/XTLS/Xray-core/releases/download/v1.5.8/Xray-linux-64.zip"
unzip -o /etc/jinggovpn/xray/Xray-linux-64.zip -d /etc/jinggovpn/xray
rm -rf /etc/jinggovpn/xray/Xray-linux-64.zip
chmod 655 /etc/jinggovpn/xray/xray

# // Uuid Service
uuid=$(cat /proc/sys/kernel/random/uuid)

# XRay boot service
cat <<EOF >/etc/systemd/system/xray.service
[Unit]
Description=Xray - A unified platform for anti-censorship
# Documentation=https://xraynt.com https://guide.v2fly.org
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=yes
ExecStart=/etc/jinggovpn/xray/xray run -confdir /etc/jinggovpn/xray/conf
Restart=on-failure
RestartPreventExitStatus=23


[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/xray@n.service
[Unit]
Description=Xray - A unified platform for anti-censorship
# Documentation=https://xraynt.com https://guide.v2fly.org
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=yes
ExecStart=/etc/jinggovpn/xray/xray run -config /etc/jinggovpn/xray/vless-nontls.json
Restart=on-failure
RestartPreventExitStatus=23


[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray.service
cat <<EOF >/etc/jinggovpn/xray/conf/00_log.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  }
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/10_ipv4_outbounds.json
{
    "outbounds":[
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv4"
            },
            "tag":"IPv4-out"
        },
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv6"
            },
            "tag":"IPv6-out"
        },
        {
            "protocol":"blackhole",
            "tag":"blackhole-out"
        }
    ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/11_dns.json
{
    "dns": {
        "servers": [
          "localhost"
        ]
  }
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/02_VLESS_TCP_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "tag": "VLESSTCP",
      "settings": {
        "clients": [],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 31296,
            "xver": 1
          },
          {
            "alpn": "h1",
            "dest": 31333,
            "xver": 0
          },
          {
            "alpn": "h2",
            "dest": 31302,
            "xver": 0
          },
          {
            "path": "/xrayws",
            "dest": 31297,
            "xver": 1
          },
          {
            "path": "/xrayvws",
            "dest": 31299,
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "minVersion": "1.2",
          "alpn": [
            "http/1.1",
            "h2"
          ],
          "certificates": [
            {
              "certificateFile": "/etc/jinggovpn/xray/xray.crt",
              "keyFile": "/etc/jinggovpn/xray/xray.key",
              "ocspStapling": 3600,
              "usage": "encipherment"
            }
          ]
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/03_VLESS_WS_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 31297,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "VLESSWS",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/xrayws"
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/04_trojan_gRPC_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
    "inbounds": [
        {
            "port": 31304,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "tag": "trojangRPCTCP",
            "settings": {
                "clients": [
                    {
      "id": "${uuid}",
                        "password": "",
                        "email": "${domain}_trojan_gRPC"
                    }
                ],
                "fallbacks": [
                    {
                        "dest": "31300"
                    }
                ]
            },
            "streamSettings": {
                "network": "grpc",
                "grpcSettings": {
                    "serviceName": "trojangrpc"
                }
            }
        }
    ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/04_trojan_TCP_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 31296,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojanTCP",
      "settings": {
        "clients": [],
        "fallbacks": [
          {
            "dest": "31300"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "acceptProxyProtocol": true
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/10_trojan_XTLS_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 31230,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojanXTLS",
      "settings": {
        "clients": [],
        "fallbacks": [
          {
            "dest": "31333"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
             "alpn": [
            "http/1.1",
            "h1"
          ]
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/05_VMess_WS_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 31299,
      "protocol": "vmess",
      "tag": "VMessWS",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/xrayvws"
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/jinggovpn/xray/conf/06_VLESS_gRPC_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
    "inbounds":[
    {
        "port": 31301,
        "listen": "127.0.0.1",
        "protocol": "vless",
        "tag":"VLESSGRPC",
        "settings": {
            "clients": [],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "grpc",
            "grpcSettings": {
                "serviceName": "vlessgrpc"
            }
        }
    }
]
}
EOF

cat >/etc/jinggovpn/xray/conf/vmess-nontls.json <<END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#xray
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/xrayws",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
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
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END

cat >/etc/jinggovpn/xray/vless-nontls.json <<END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error2.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 8088,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}"
#xray
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/xrayws",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
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
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END

# xray
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31301 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31299 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31296 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31304 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31297 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31230 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8088-j ACCEPT
# xray
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31301 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31299 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31296 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31304 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31297 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31230 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8088 -j ACCEPT
iptables-save >/etc/iptables.rules.v4
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload

# Starting
systemctl daemon-reload
systemctl restart xray
systemctl enable xray
systemctl restart xray.service
systemctl enable xray.service
systemctl restart xray@n.service
systemctl enable xray@n.service

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