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

set-dns() {
    yell='\e[1;33m'
    NC='\e[0m'
    cpath="/etc/openvpn/server/server-tcp-1194.conf"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • CUSTOM DNS •                    \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " • Default DNS  : 8.8.8.8"
    echo -ne " • Set New DNS : "
    read controld
    [[ -z $controld ]] && controld="8.8.8.8"
    [[ ! -f /etc/resolvconf/interface-order ]] && {
        apt install resolvconf
    }
    echo "nameserver $controld" >/etc/resolvconf/resolv.conf.d/head
    echo "nameserver $controld" >/etc/resolv.conf

    sed -i "/dhcp-option DNS/d" $cpath
    sed -i "/redirect-gateway def1 bypass-dhcp/d" $cpath
    cat >>$cpath <<END
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS $controld"
END

    [[ ! -f /usr/bin/jq ]] && {
        apt install jq
    }
    bash <(curl -sSL https://raw.githubusercontent.com/seliparjp/xiomiWRT/main/ck.sh)
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo -ne "\n[ ${yell}WARNING${NC} ] Do you want to reboot now ? (y/n)? "
    read answer
    if [ "$answer" == "${answer#[Yy]}" ]; then
        exit 0
    else
        reboot
    fi
}

check-dns() {
    bash <(curl -sSL https://raw.githubusercontent.com/seliparjp/xiomiWRT/main/ck.sh)
    echo -e ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • CUSTOM DNS •                    \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " [\e[36m01\e[0m] Setup DNS"
    echo -e " [\e[36m02\e[0m] Check DNS Region"
    echo -e ""
    echo -e " [00] • Back to Main Menu \033[1;32m<\033[1;33m<\033[1;31m<\033[1;31m"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -p " Select menu : " opt
    echo -e ""
    case $opt in
    1 | 01)
    clear
    set-dns
    ;;
    2 | 02)
    clear
    check-dns
    ;;
    00)
    clear
    menu
    ;;
    x) exit ;;
    *)
    clear
    dns
    ;;
esac
