#!/bin/bash
#
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
# ==================================================

# // initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

# // Domain
domain=$(cat /root/domain)

# // detail nama perusahaan
country=MY
state=Malaysia
locality=Malaysia
organization=jinggo
organizationalunit=jinggo
commonname=jinggo.xyz
email=jinggovpn@gmail.com

# // simple password minimal
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/password"
chmod +x /etc/pam.d/common-password

# // go to root
cd

# // Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# // nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# // Ubah izin akses
chmod +x /etc/rc.local

# // enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# // disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# // update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# // Install Wget And Curl
apt -y install wget curl

# // Install Requirements Tools
apt install ruby -y
apt install python -y
apt install make -y
apt install cmake -y
apt install coreutils -y
apt install rsyslog -y
apt install net-tools -y
apt install zip -y
apt install unzip -y
apt install nano -y
apt install sed -y
apt install gnupg -y
apt install gnupg1 -y
apt install bc -y
apt install jq -y
apt install apt-transport-https -y
apt install build-essential -y
apt install dirmngr -y
apt install libxml-parser-perl -y
apt install git -y
apt install lsof -y
apt install libsqlite3-dev -y
apt install libz-dev -y
apt install gcc -y
apt install g++ -y
apt install libreadline-dev -y
apt install zlib1g-dev -y
apt install libssl-dev -y
apt install libssl1.0-dev -y
apt install dos2unix -y
apt install curl -y
apt install pwgen openssl netcat cron -y
apt install socat -y
echo "clear" >> .profile
echo "jinggo" >> .profile

# // set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
date

# // set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# // install Fix
apt-get --reinstall --fix-missing install -y linux-headers-cloud-amd64 bzip2 gzip coreutils wget jq screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl git lsof


# // Nginx
installType='apt -y install'
source /etc/os-release
release=$ID
ver=$VERSION_ID

if [[ "${release}" == "debian" ]]; then
		sudo apt install gnupg2 ca-certificates lsb-release -y 
		echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list 
		echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
		curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key 
		# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
		sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
		sudo apt update 
                apt -y install nginx

elif [[ "${release}" == "ubuntu" ]]; then
		sudo apt install gnupg2 ca-certificates lsb-release -y 
		echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
		echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
		curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
		# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
		sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
		sudo apt update 
                apt -y install nginx
fi

systemctl daemon-reload
systemctl enable nginx
ufw disable
touch /etc/nginx/conf.d/alone.conf
cat <<EOF >>/etc/nginx/conf.d/alone.conf
server {
             listen 80;
             listen [::]:80;
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;	
             server_name ${domain};
             ssl_certificate /etc/jinggovpn/tls/xray.crt;
             ssl_certificate_key /etc/jinggovpn/tls/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /usr/share/nginx/html;

             location = /vless {
                       proxy_redirect off;
                       proxy_pass http://127.0.0.1:14016;
                       proxy_http_version 1.1;
             proxy_set_header X-Real-IP aaa;
             proxy_set_header X-Forwarded-For bbb;
             proxy_set_header Upgrade ddd;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host ccc;
 }
             location = /vmess {
                       proxy_redirect off;
                       proxy_pass http://127.0.0.1:23456;
                       proxy_http_version 1.1;
             proxy_set_header X-Real-IP aaa;
             proxy_set_header X-Forwarded-For bbb;
             proxy_set_header Upgrade ddd;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host ccc;
 }
             location = /trojan-ws {
                       proxy_redirect off;
                       proxy_pass http://127.0.0.1:25432;
                       proxy_http_version 1.1;
             proxy_set_header X-Real-IP aaa;
             proxy_set_header X-Forwarded-For bbb;
             proxy_set_header Upgrade ddd;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host ccc;
 }
             location = /ss-ws {
                      proxy_redirect off;
                      proxy_pass http://127.0.0.1:30300;
                      proxy_http_version 1.1;
             proxy_set_header X-Real-IP aaa;
             proxy_set_header X-Forwarded-For bbb;
             proxy_set_header Upgrade ddd;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host ccc;
 }
             location ^~ /vless-grpc {
                      proxy_redirect off;
                      grpc_set_header X-Real-IP aaa;
                      grpc_set_header X-Forwarded-For bbb;
             grpc_set_header Host ccc;
             grpc_pass grpc://127.0.0.1:24456;
 }
             location ^~ /vmess-grpc {
                      proxy_redirect off;
                      grpc_set_header X-Real-IP aaa;
                      grpc_set_header X-Forwarded-For bbb;
             grpc_set_header Host ccc;
             grpc_pass grpc://127.0.0.1:31234;
 }
             location ^~ /trojan-grpc {
                      proxy_redirect off;
                      grpc_set_header X-Real-IP aaa;
                      grpc_set_header X-Forwarded-For bbb;
             grpc_set_header Host ccc;
             grpc_pass grpc://127.0.0.1:33456;
 }
             location ^~ /ss-grpc {
                      proxy_redirect off;
                      grpc_set_header X-Real-IP aaa;
                      grpc_set_header X-Forwarded-For bbb;
             grpc_set_header Host ccc;
             grpc_pass grpc://127.0.0.1:30310;
 }
             location  /fallback {
                      proxy_redirect off;
                      proxy_pass http://127.0.0.1:8880;
                      proxy_http_version 1.1;
              proxy_set_header Upgrade ddd;
              proxy_set_header Connection upgrade;
              proxy_set_header Host ccc;
              proxy_cache_bypass ddd;
  }
        }	
EOF

# // Move
sed -i 's/aaa/$remote_addr/g' /etc/nginx/conf.d/alone.conf
sed -i 's/bbb/$proxy_add_x_forwarded_for/g' /etc/nginx/conf.d/alone.conf
sed -i 's/ccc/$host/g' /etc/nginx/conf.d/alone.conf
sed -i 's/ddd/$http_upgrade/g' /etc/nginx/conf.d/alone.conf

# // Certv2ray
curl -s https://get.acme.sh | sh
/root/.acme.sh/acme.sh  --upgrade  --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --listen-v6 --force >> /etc/jinggovpn/tls/$domain.log
~/.acme.sh/acme.sh --installcert -d ${domain} --fullchainpath /etc/jinggovpn/tls/xray.crt --keypath /etc/jinggovpn/tls/xray.key --ecc
cat /etc/jinggovpn/tls/$domain.log

sleep 1
clear

# // Boot Nginx
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
rm /etc/nginx/conf.d/default.conf
systemctl daemon-reload
service nginx restart
cd

# // Html
rm -rf /usr/share/nginx/html
wget -q -P /usr/share/nginx https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/html.zip 
unzip -o /usr/share/nginx/html.zip -d /usr/share/nginx/html 
rm -f /usr/share/nginx/html.zip*

curl https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/nginx.conf > /etc/nginx/nginx.conf
curl https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/vps.conf > /etc/nginx/conf.d/vps.conf
mkdir -p /home/vps/public_html

# // install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500


# // setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config

# // install dropbear
apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

# // install squid
cd
apt -y install squid3
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf

# // Setting Vnstat
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6

# // install stunnel
apt install stunnel4 -y

cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 444
connect = 127.0.0.1:109

[dropbear]
accept = 777
connect = 127.0.0.1:22

END

# // make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# // konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

#sshws
apt -y install python
apt -y install tmux
apt -y install ruby
gem install lolcat
apt -y install figlet
wget -q https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/edu.sh && chmod +x edu.sh && ./edu.sh

# // OpenVPN
wget https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/vpn.sh && chmod +x vpn.sh && ./vpn.sh

# // install fail2ban
apt install -y dnsutils tcpdump dsniff grepcidr
apt -y install fail2ban

# // Instal DDOS Flate
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.ctohome.com/linux-vps-pack/soft/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.ctohome.com/linux-vps-pack/soft/ddos/ignore.ip.list

/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" >>  /usr/local/ddos/ignore.ip.list;
chattr +i /usr/local/ddos/ignore.ip.list;

echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.ctohome.com/linux-vps-pack/soft/ddos/ddos-deflate.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'

echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'DOS-Deflate Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'


# banner /etc/issue.net
wget -O /etc/issue.net "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/SSHOVPN/issue.net"
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

# // blockir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# // download script
cd /usr/local/bin

# // menu ssh-ovpn

wget -O usernew "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/trial.sh"
wget -O renew "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/renew.sh"
wget -O hapus "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/cek.sh"
wget -O delete "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/delete.sh"
wget -O ceklim "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/ceklim.sh"
wget -O restart "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/restart.sh"
wget -O autokill "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/autokill.sh"
wget -O tendang "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/tendang.sh"
wget -O member "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/member.sh"


# // menu system
wget -O add-host "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/add-host.sh"
wget -O speedtest "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/speedtest_cli.py"
wget -O wbmn "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/webmin.sh"
wget -O jinggo "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/jinggo.sh"
wget -O restart-service "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/restart-service.sh"
wget -O ram "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/ram.sh"
wget -O info "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/info.sh"
wget -O nf "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/V1/nf.sh"
wget -O mdns "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/mdns.sh"
wget -O bbr "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/bbr.sh"
wget -O recert-xray "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/recert-xray.sh"
wget -O status "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/status.sh"
wget -O change "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/change.sh"

# // change port
wget -O port-ovpn "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/port-ovpn.sh"
wget -O port-ssl "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/port-ssl.sh"
wget -O port-squid "https://raw.githubusercontent.com/jinGGo007/PRIVATE/main/MENU/port-squid.sh"
wget -O port-tls "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/port-tls.sh"
wget -O port-ntls "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/port-ntls.sh"

# menu
wget -O menu "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/menu.sh"

# // xpired
wget -O delexp "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/XRAY/delexp.sh"
wget -O clear-log "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/clear-log.sh"
wget -O clearcache "https://raw.githubusercontent.com/jinGGo007/MULTIPORT/main/clearcache.sh"

chmod +x usernew
chmod +x trial
chmod +x renew
chmod +x hapus
chmod +x cek
chmod +x delete
chmod +x ceklim
chmod +x autokill
chmod +x restart
chmod +x tendang
chmod +x member

chmod +x add-host
chmod +x speedtest
chmod +x wbmn
chmod +x jinggo
chmod +x restart-service
chmod +x ram
chmod +x info
chmod +x nf
chmod +x mdns
chmod +x bbr
chmod +x recert-xray
chmod +x status
chmod +x change


chmod +x port-ssl
chmod +x port-ovpn
chmod +x port-tls
chmod +x port-ntls

chmod +x menu

chmod +x clear-log
chmod +x clearcache
chmod +x delexp

cd

echo "0 */12 * * * root /usr/local/bin/clear-log # clear log every  two hours" >> /etc/crontab
echo "0 */12 * * * root /usr/local/bin/clearcache  #clear cache every 12hours daily" >> /etc/crontab
echo "0 8 * * * root /usr/local/bin/delete # delete expired user" >> /etc/crontab
echo "0 0 * * * root /usr/local/bin/delexp # delete expired user" >> /etc/crontab
echo "0 5 * * * root reboot" >> /etc/crontab

# // remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

# // finishing
cd
chown -R www-data:www-data /home/vps/public_html
chown -R www-data:www-data /usr/share/nginx/html

/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/stunnel4 restart
/etc/init.d/vnstat restart
/etc/init.d/squid restart
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500

history -c
cd
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh

# // finihsing
clear
echo -e "${RED}SSH-VPN INSTALL DONE${NC} "
sleep 2