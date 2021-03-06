#!/usr/bin/env bash
#Dnspod DDNS with BashShell
#Github:https://github.com/kkkgo/dnspod-ddns-with-bashshell
#More: https://03k.org/dnspod-ddns-with-bashshell.html
#CONF START
#
#
#see : https://github.com/Buffer2Disk/dnspod-ddns-with-bashshell
#crontab : */1 * * * * /root/dnspod_ddns.sh &> /var/log/hkt-dnspod-ddns.log
#          */1 * * * * /root/dnspod_ddns.sh &> /dev/null
API_ID=12345
API_Token=abcdefghijklmnopq2333333
domain=example.com
host=home
CHECKURL="http://ip.sb"
#OUT="pppoe"
#CONF END

TG_ENABLE="1"   #是否开启Telegram提醒
TG_API_URL="api.telegram.org"  #Telegram API地址（可以反代）
Telegram_Bot_Api_Key="*********"  #Telegram bot api key
Telegram_User_ID="*********"   #你的Telegram 用户ID

Send_TG_Message(){
	Message="$1"
	if [[ "${TG_ENABLE}" -eq 1 ]] ; then
		SendMessage=$( curl -s -g "https://${TG_API_URL}/bot${Telegram_Bot_Api_Key}/sendMessage?chat_id=${Telegram_User_ID}&text=${Message}&parse_mode=markdown" )
		Check=$( echo "${SendMessage}" | grep "true" )
		if [[ -n "${Check}" ]] ; then
			echo -e "Telegram message sent successful."
		else
			echo -e "Telegram message sent failed. ${SendMessage}"
		fi
	else
		echo -e "Telegram reminder has been disabled,unsent message."
	fi
}

date
if (echo $CHECKURL |grep -q "://");then
IPREX='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
URLIP=$(curl -4 -k $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -s $CHECKURL|grep -Eo "$IPREX"|tail -n1)
if (echo $URLIP |grep -qEvo "$IPREX");then
URLIP="Get $DOMAIN URLIP Failed."
echo "[URL IP]:$URLIP"
exit
fi
echo "[URL IP]:$URLIP"
dnscmd="nslookup";type nslookup >/dev/null 2>&1||dnscmd="ping -c1"
DNSTEST=$($dnscmd $host.$domain)
if [ "$?" != 0 ]&&[ "$dnscmd" == "nslookup" ]||(echo $DNSTEST |grep -qEvo "$IPREX");then
DNSIP="Get $host.$domain DNS Failed."
else DNSIP=$(echo $DNSTEST|grep -Eo "$IPREX"|tail -n1)
fi
echo "[DNS IP]:$DNSIP"
if [ "$DNSIP" == "$URLIP" ];then
echo "IP SAME IN DNS,SKIP UPDATE."
exit
fi
fi
token="login_token=${API_ID},${API_Token}&format=json&lang=en&error_on_empty=yes&domain=${domain}&sub_domain=${host}"
UA="User-Agent: 03K MyMachine/1.0.0 ($Email)"
Record="$(curl -4 -k $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -s -X POST https://dnsapi.cn/Record.List -d "${token}" -H "${UA}")"
iferr="$(echo ${Record#*code}|cut -d'"' -f3)"
if [ "$iferr" == "1" ];then
record_ip=$(echo ${Record#*value}|cut -d'"' -f3)
echo "[API IP]:$record_ip"
if [ "$record_ip" == "$URLIP" ];then
echo "IP SAME IN API,SKIP UPDATE."
exit
fi

Send_TG_Message "ip变动通知，域名***${host}*** 所属ip发生变动，请等待ddns更新,旧的ip:    ***${record_ip}***     更换为新ip:    ***${URLIP}***"

record_id=$(echo ${Record#*\"records\"\:\[\{\"id\"}|cut -d'"' -f2)
record_line_id=$(echo ${Record#*line_id}|cut -d'"' -f3)
echo Start DDNS update...
ddns="$(curl -4 -k $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -s -X POST https://dnsapi.cn/Record.Ddns -d "${token}&record_id=${record_id}&record_line_id=${record_line_id}" -H "${UA}")"
ddns_result="$(echo ${ddns#*message\"}|cut -d'"' -f2)"
echo -n "DDNS upadte result:$ddns_result "
echo $ddns|grep -Eo "$IPREX"|tail -n1
else echo -n Get $host.$domain error :
echo $(echo ${Record#*message\"})|cut -d'"' -f2
fi
