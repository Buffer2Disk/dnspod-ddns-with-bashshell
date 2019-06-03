#!/usr/bin/env bash
#centos7 循环换ip脚本，直到换到不同的ip为止；centos6也适用，dns会被重置，可以自己去改回来
#由于更换ip后会导致当前ssh断开连接，建议配合 发送消息给tg机器人的脚本  共同使用，防止小鸡失联！！
#重置dhclient会导致dns被重置成默认的，你可以自己手动改回来
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
CHECKURL="http://ip.sb"


#查询当前ip的函数
getUrlIP(){
    if (echo $CHECKURL |grep -q "://");then
        IPREX='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
        URLIP=$(curl -4 -k $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -s $CHECKURL|grep -Eo "$IPREX"|tail -n1)
        if (echo $URLIP |grep -qEvo "$IPREX");then
            URLIP="Get $DOMAIN URLIP Failed."
            echo "[URL IP]:$URLIP"
        fi
    fi
    echo "$URLIP"
}

oldIP=$(getUrlIP)
echo "old ip is : $oldIP"
while true;do
   dhclient -r -v
   rm -rf /var/lib/dhclient/*
   dhclient -v
   service network restart
   newIP=$(getUrlIP)
   echo "new ip is -------> $newIP"
   if [ "$oldIP" != "$newIP" ];then
   	   echo "change ip success, new ip is --------> $newIP"
       break
   fi
   sleep 2
done
