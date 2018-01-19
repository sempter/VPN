#!/bin/bash

echo "$(date)"
echo "vpn"
IP="10.171.39.40"
export PATH
startOpenvpnFlag=`ps -ef | grep -i '/etc/openvpn/clien_sepj.ovpn' | grep -v grep | wc -l`

function startOpenVpn() {
        /usr/sbin/openvpn /etc/openvpn/client_pay.ovpn >/dev/null &
}

function checkPingIp() {
        ip=$1
        checkPingPackageNum=`ping $ip -c 4 | awk '{if($0~/packets transmitted/){split($6,a,"%");print a[1];}}'`
        if [ $checkPingPackageNum -eq 100 ];then
                kill -9 `ps -ef | grep -i '/etc/openvpn/client_pay.ovpn' | grep -v grep | awk '{print $2}'`
                startOpenVpn
        elif [ $checkPingPackageNum -ne 100 ];then
                echo "ping $ip is ok"
        fi
}

if [ $startOpenvpnFlag -eq 0 ];then
        startOpenVpn
        sleep 5
        checkPingIp $IP
elif [ $startOpenvpnFlag -eq 1 ];then
        checkPingIp $IP
fi

echo "route"
ip="waterrds.mysql.rds.aliyuncs.com"
checkPingMysql=`ping $ip -c 4 | awk '{if($0~/packets transmitted/){split($6,a,"%");print a[1];}}'`
if [ $checkPingMysql -eq 100 ];then
	sh /usr/local/yunwei/route.sh
elif [ $checkPingMysql -ne 100 ];then
        echo "ping $ip is ok"
fi

