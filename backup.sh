#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

MYIP=$(curl -sS ipv4.icanhazip.com)
IPVPSS=$(cat /etc/samvpn/xray/scvpn/.ipvps)
uvers=$(cat /etc/samvpn/xray/scvpn/.version)
uname=$(cat /etc/samvpn/xray/scvpn/.cilname)
uexpd=$(cat /etc/samvpn/xray/scvpn/.expdead)

CEKEXPIRED () {
    today=$(date -d +1day +%Y-%m-%d)
    Exp1=$(curl -sS https://raw.githubusercontent.com/seliparjp/access/main/ipvps | grep $IPVPSS | awk '{print $3}')
    if [[ $today < $Exp1 ]]; then
    echo -e "\n${green}Permission Accepted...${NC}"
    else
    echo -e "\n${red}Permission Denied!${NC}";
    exit 0
fi
}
IZIN=$(curl -sS https://raw.githubusercontent.com/seliparjp/access/main/ipvps | awk '{print $4}' | grep $IPVPSS)
if [ "$IPVPSS" = "$IZIN" ]; then
echo -e "$\n{green}Permission Accepted...${NC}"
CEKEXPIRED
else
echo -e "\n${red}Permission Denied!${NC}";
rm -f setup.sh
exit 0
fi
clear


echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[40;1;37m|            • CERT / RENEW DOMAIN •             |\E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "" 
echo -e "[ ${green}INFO${NC} ] Start " 
sleep 0.5
domain=$(cat /etc/samvpn/xray/domain)
echo -e "[ ${green}INFO${NC} ] Starting renew cert... " 
sleep 3
sudo pkill -f nginx &
wait $!
systemctl stop nginx
systemctl stop xray.service
systemctl stop xray@n
sleep 2
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256 --server letsencrypt >>/etc/samvpn/tls/$domain.log
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/samvpn/xray/xray.crt --keypath /etc/samvpn/xray/xray.key --ecc
cat /etc/samvpn/tls/$domain.log
systemctl daemon-reload
systemctl restart xray@n
systemctl restart xray.service
systemctl stop nginx
rm /etc/nginx/conf.d/xasdhxzasd.conf
touch /etc/nginx/conf.d/xasdhxzasd.conf
cat <<EOF >>/etc/nginx/conf.d/xasdhxzasd.conf
server {
	listen 81;
	listen [::]:81;
	server_name ${domain};
	# shellcheck disable=SC2154
	return 301 https://${domain};
}
server {
		listen 127.0.0.1:31300;
		server_name _;
		return 403;
}
server {
	listen 127.0.0.1:31302 http2;
	server_name ${domain};
	root /usr/share/nginx/html;
	location /s/ {
    		add_header Content-Type text/plain;
    		alias /etc/samvpn/config-url/;
    }
    location /xraygrpc {
		client_max_body_size 0;
#		keepalive_time 1071906480m;
		keepalive_requests 4294967296;
		client_body_timeout 1071906480m;
 		send_timeout 1071906480m;
 		lingering_close always;
 		grpc_read_timeout 1071906480m;
 		grpc_send_timeout 1071906480m;
		grpc_pass grpc://127.0.0.1:31301;
	}
	location /xraytrojangrpc {
		client_max_body_size 0;
		# keepalive_time 1071906480m;
		keepalive_requests 4294967296;
		client_body_timeout 1071906480m;
 		send_timeout 1071906480m;
 		lingering_close always;
 		grpc_read_timeout 1071906480m;
 		grpc_send_timeout 1071906480m;
		grpc_pass grpc://127.0.0.1:31304;
	}
}
server {
	listen 127.0.0.1:31300;
	server_name ${domain};
	root /usr/share/nginx/html;
	location /s/ {
		add_header Content-Type text/plain;
		alias /etc/samvpn/config-url/;
	}
	location / {
		add_header Strict-Transport-Security "max-age=15552000; preload" always;
	}
}
EOF
    systemctl daemon-reload
    service nginx restart
    
echo -e "[ ${green}INFO${NC} ] Renew cert done... " 
sleep 2
echo -e "[ ${green}INFO${NC} ] Starting service $Cek " 
sleep 2
echo -e "[ ${green}INFO${NC} ] All finished... " 
sleep 0.5
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
