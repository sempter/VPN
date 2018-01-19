#!/bin/bash
# function: it can access aliNet and check the linking 
# aliNet, if it does't work to link aliNet,it will restart
# openvpn process.

function exportPath() {

    PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
    export PATH

}

function trapSignal() {

    trap "clearOpenvpnRoute" 1 2 15

}

function checkstartOpenvpnProcess() {

    startOpenvpnFlagNum=`ps -ef | grep -i "startopenvpn.bash" | grep -v grep | wc -l` 
    if [ $startOpenvpnFlagNum -gt 3 ] 2>/dev/null;then
	startOpenvpnPidArray=`ps -ef | grep -i "startopenvpn.bash" | grep -v grep | head -2 | awk '{print $2}'` 	
	startOpenvpnTailPid=`ps -ef | grep -i "startopenvpn.bash" | grep -v grep | head -2 | awk '{print $2}' | tail -1` 	
	for pid in $startOpenvpnPidArray
	do
		if [ $pid -ne $startOpenvpnTailPid ];then
			kill -9 $pid
		fi
	done
    fi
}

function  killOpenvpnProcess() {

    echo "============ killOpenvpnProcess  ========"
    /etc/init.d/openvpn stop
    ps -ef | grep -i 'gaoZhiAcessAli.ovpn' | grep -v grep | awk '{print $2}' | xargs kill -9  2>/dev/null
    sleep 3
    openvpnProcessNum=`ps -ef | grep -i 'gaoZhiAcessAli.ovpn' | grep -v grep | wc -l`
    if [ $openvpnProcessNum -eq 0 ];then
	echo 
        echo "killOpenvpnProcess successfully! "
        echo
    fi
}

function startOpenvpn() {

    echo "============= startOpenvpn ============="
    /usr/bin/nohup /usr/sbin/openvpn /etc/openvpn/gaoZhiAcessAli.ovpn >/dev/null &
    sleep 2
    ps -ef | grep -i 'openvpn/gaoZhiAcessAli.ovpn' | grep -v grep
    echo

}

function setOpenvpnRoute() {

    route -n | awk '$1~/10\.8\.0\.1$/{print $2}' | perl -ane 'if($F[0]=~/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/){ \
        print  "============= setOpenvpnRoute =============\n";
	print "get gateway  $F[0]\n";
        $gateway = $F[0];
    #   system("setIptables");
	system("route del -net 0.0.0.0   netmask 128.0.0.0  gw  $gateway  dev tun0 2>/dev/null");
	system("route del -net 128.0.0.0 netmask 128.0.0.0  gw  $gateway  dev tun0 2>/dev/null");
	system("route add -net 10.0.0.0  netmask 255.0.0.0  gw  $gateway  dev tun0");
	system("route add -net 100.0.0.0 netmask 255.0.0.0  gw  $gateway  dev tun0");
      }'
    route -n
    echo

}

function setIptables() {

    ifconfig -a | grep -A1 'tun0' | grep inet | awk '{split($2, a, /:/);print a[2]}' | perl -ane 'if($F[0]=~/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/){ \
        print "============= setIptables =============\n";
	print "get openvpnip $F[0]\n";
	$openvpnIp = $F[0];
	system("iptables -t nat -F POSTROUTING");
	system("iptables -t nat -A POSTROUTING  -s 192.168.88.1/32 -o eth0 -j MASQUERADE");
	system("iptables -t nat -A POSTROUTING -o tun7 -s 192.168.40.0/24 -d 172.18.176.0/20 -j MASQUERADE");
	system("iptables -t nat -A POSTROUTING -o tun7 -s 192.168.88.1/32 -d 172.18.176.0/20 -j MASQUERADE");
#	system("iptables -t nat -A POSTROUTING -o tun0 -s 192.168.40.0/24  -d 10.0.0.0/8 -j SNAT --to-source  $openvpnIp");
#	system("iptables -t nat -A POSTROUTING -o tun0 -s 192.168.40.0/24  -d 100.0.0.0/8 -j SNAT --to-source $openvpnIp"); 
	system("iptables -t nat -A POSTROUTING -o tun0 -s 192.168.40.0/24  -d 100.0.0.0/8 -j MASQUERADE"); 
	system("iptables -t nat -A POSTROUTING -o tun0 -s 192.168.40.0/24  -d 10.0.0.0/8  -j MASQUERADE"); 
	system("iptables -t nat -A POSTROUTING -o tun0 -s 192.168.77.1/32  -d 10.0.0.0/8  -j MASQUERADE"); 
	system("iptables -t nat -A POSTROUTING -o tun0 -s 192.168.77.1/32  -d 100.0.0.0/8  -j MASQUERADE"); 
	system("iptables -t nat -A POSTROUTING -o eth0 -s 192.168.77.1/32  -d 192.168.40.0/24  -j MASQUERADE"); 
	system("iptables -t nat -A POSTROUTING -o eth0 -s 192.168.77.1/32  -d 192.168.1.0/24  -j MASQUERADE"); 
	system("iptables -t nat -A POSTROUTING -o tun7 -s 192.168.77.1/32 -d 172.18.176.0/20 -j MASQUERADE");
      }'
    iptables -t nat -L -n	
    echo

}

function clearOpenvpnRoute() {

    echo "============= clearOpenvpnRoute ============="
    sleep 5
    /sbin/route -n | perl -ane \
     'if($_=~/^(10|101|100)/) {
         system("/sbin/route del -net $F[0] netmask $F[2]");
     }'
    /sbin/route -n
    echo
}

function checkLinkInternet() {

   checkFlag=`ping 182.92.159.4 -c 10 | perl -ane 'if($_=~/,\s(\d+)%\spacket\sloss/){print $1}'`
   echo "================ check link 182.92.159.4 =================="
   if [ $checkFlag -ge 50 ];then
       echo "$checkFlag% packet loss"
       echo "182.92.159.4 is unreached."
       echo 
       exit 1
   else 
       echo "$checkFlag% packet loss"
       echo "link 182.92.159.4 is ok"
       echo
   fi

}

function checkLinkAliNet() {

   checkFlag=`ping 10.172.182.35 -c 4 | perl -ane 'if($_=~/,\s(\d+)%\spacket\sloss/){print $1}'`
   echo "================ check link 10.172.182.35 AliNet ================"
   if [ $checkFlag -ge 50 ];then
       echo "$checkFlag% packet loss"
       echo "10.172.182.35 AliNet is unreached."
       echo 
   else
       echo "$checkFlag% packet loss"
       echo "link 10.172.182.35 is ok"
       echo
       exit 0 
   fi

}

function printDate() {

   echo "当前输出信息时间: `date +"%F %H:%M:%S"`"

}

function checkSshTunnel() {

#   sshTunnelNumber=`netstat -tunp | grep -i 'ssh' | grep -i '123.57.89.156:13710' | wc -l`
   sshTunnelDocserverNumber=`ssh root@123.57.89.156 -p 13710 "netstat -tlunp | grep -i 13767" | wc -l`
   sshTunnelqqmywxtNumber=`ssh root@123.57.89.156 -p 13710 "netstat -tlunp | grep -i 13789" | wc -l`

   if [ $sshTunnelDocserverNumber -eq 0 ];then

        ssh -fgCNR 13767:localhost:13766 root@123.57.89.156 -p 13710

   fi

   if [ $sshTunnelqqmywxtNumber -eq 0 ];then

        ssh -fgCNR 13789:localhost:13788 root@123.57.89.156 -p 13710

   fi
#   if [ $sshTunnelNumber -ne 2 ];then
#
#        netstat -tunp | grep -i 'ssh' | grep -i '123.57.89.156:13710'  | awk '$7~/ssh/{split($7,a,"/");print a[1]}' | while read pid;do \
#        ps -ef | grep -i $pid; kill -9 $pid; done;
#        
#        ssh -fgCNR 13789:localhost:13788 root@123.57.89.156 -p 13710
#        ssh -fgCNR 13767:localhost:13766 root@123.57.89.156 -p 13710
#   
#   fi 

}

function main() {

    exportPath
    trapSignal
    printDate
#    checkSshTunnel
    checkstartOpenvpnProcess
    checkLinkInternet
    while [ 1 ]
    do
	    checkLinkAliNet
	    killOpenvpnProcess
	    clearOpenvpnRoute
	    startOpenvpn
	    sleep 13
	    setIptables
#	    setOpenvpnRoute
	    checkLinkAliNet
            sleep 120
    done

}
   main

