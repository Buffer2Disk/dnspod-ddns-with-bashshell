#!/usr/bin/env bash
#请记得执行 chmod+x xxx.sh
domain=example.com
host=www #填你的二级域名
CHECKURL="http://ip.sb"

TG_ENABLE="1"   #是否开启Telegram提醒
TG_API_URL="api.telegram.org"  #Telegram API地址（国内服务器可以反代）
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

Send_TG_Message "ip变动通知，域名***${host}*** 所属ip发生变动，请等待ddns更新,旧的ip:    ***${DNSIP}***     更换为新ip:    ***${URLIP}***"