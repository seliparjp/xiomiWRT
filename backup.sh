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

backup_data() {
    green='\e[0;32m'
    NC='\e[0m'
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[40;1;37m|                • BACKUP DATA •                 |\E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\n[ ${green}INFO${NC} ] Create password for database"
    read -rp "[ INFO ] Enter password : " -e InputPass
    sleep 1
    if [[ -z $InputPass ]]; then
        menu
    fi
    echo -e "[ ${green}INFO${NC} ] Processing... "
    mkdir -p /root/backup
    sleep 1

    cp /etc/passwd backup/
    cp /etc/group backup/
    cp /etc/shadow backup/
    cp /etc/gshadow backup/
    cp /etc/samvpn/xray/user.txt backup/
    cp -r /etc/samvpn/xray/conf backup/conf

    cd /root
    zip -rP $InputPass $Name.zip backup >/dev/null 2>&1

    ##############++++++++++++++++++++++++#############
    LLatest=$(date)
    Get_Data() {
        git clone https://github.com/syfqsamvpn/user-backup-db.git /root/user-backup/ &>/dev/null
    }

    Mkdir_Data() {
        mkdir -p /root/user-backup/$Name
    }

    Input_Data_Append() {
        if [ ! -f "/root/user-backup/$Name/$Name-last-backup" ]; then
            touch /root/user-backup/$Name/$Name-last-backup
        fi
        echo -e "User         : $Name
last-backup : $LLatest
" >>/root/user-backup/$Name/$Name-last-backup
        mv /root/$Name.zip /root/user-backup/$Name/
    }

    Save_And_Exit() {
        cd /root/user-backup
        git config --global user.email "syfqpubg5@gmail.com" &>/dev/null
        git config --global user.name "syfqsamvpn" &>/dev/null
        rm -rf .git &>/dev/null
        git init &>/dev/null
        git add . &>/dev/null
        git commit -m m &>/dev/null
        git branch -M main &>/dev/null
        git remote add origin https://github.com/syfqsamvpn/user-backup-db
        git push -f https://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@github.com/syfqsamvpn/user-backup-db.git &>/dev/null
    }

    if [ ! -d "/root/user-backup/" ]; then
        sleep 1
        echo -e "[ ${green}INFO${NC} ] Getting database... "
        Get_Data
        Mkdir_Data
        sleep 1
        echo -e "[ ${green}INFO${NC} ] Getting info server... "
        Input_Data_Append
        sleep 1
        echo -e "[ ${green}INFO${NC} ] Processing updating server...... "
        Save_And_Exit
    fi
    link="https://raw.githubusercontent.com/syfqsamvpn/user-backup-db/main/$Name/$Name.zip"
    sleep 1
    echo -e "[ ${green}INFO${NC} ] Backup done "
    sleep 1
    echo
    sleep 1
    echo -e "[ ${green}INFO${NC} ] Generete Link Backup "
    echo
    sleep 2
    echo -e "The following is a link to your vps data backup file.
Your VPS IP $IP
$link
save the link pliss!
If you want to restore data, please enter the link above.
Thank You For Using Our Services"

    rm -rf /root/backup &>/dev/null
    rm -rf /root/user-backup &>/dev/null
    rm -f /root/$Name.zip &>/dev/null
    echo
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

restore_data() {
    green='\e[0;32m'
    NC='\e[0m'
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[40;1;37m|               • RESTORE DATA •                 |\E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Link : " link
    read -p "Pass : " InputPass
    mkdir /root/backup
    wget -q -O /root/backup/backup.zip "$link" &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Getting your data..."
    unzip -P $InputPass /root/backup/backup.zip &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Starting to restore data..."
    rm -f /root/backup/backup.zip &>/dev/null
    sleep 1
    cd /root/backup
    echo -e "[ ${green}INFO${NC} ] • Restoring passwd data..."
    sleep 1
    cp /root/backup/passwd /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring group data..."
    sleep 1
    cp /root/backup/group /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring shadow data..."
    sleep 1
    cp /root/backup/shadow /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring gshadow data..."
    sleep 1
    cp /root/backup/gshadow /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring Xray data..."
    sleep 1
    cp /root/backup/user.txt /etc/samvpn/xray/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring admin data..."
    sleep 1
    cp -r /root/backup/conf /etc/samvpn/xray &>/dev/null
    rm -rf /root/backup &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Done..."
    sleep 1
    rm -f /root/backup/backup.zip &>/dev/null
    systemctl restart xray.service
    systemctl restart xray@n
    systemctl restart xray.service
    echo
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    eco -e ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[40;1;37m|             • BACKUP & RESTORE •               |\E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " [\e[36m01\e[0m] Backup Data"
    echo -e " [\e[36m02\e[0m] Restore Data"
    echo -e ""
    echo -e "\n[00] • Back to Main Menu \033[1;32m<\033[1;33m<\033[1;31m<\033[1;31m"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -p " Select menu : " opt
    echo -e ""
    case $opt in
    1 | 01)
    clear
    restore_data
    ;;
    2 | 02)
    clear
    backup_data
    ;;
    00)
    clear
    menu
    ;;
    x) exit ;;
    *)
    clear
    backup
    ;;
esac
