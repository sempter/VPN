#!/bin/bash
# function: it can match mac for accessing 192.168.1.0/24 lan.


function exportPath() {

	PATH=/usr/local/node/node-v4.6.0-linux-x64/bin:/usr/local/nginx/sbin:/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
	export PATH
}

function letSetRulesAccess() {

	iptables -P FORWARD DROP
	iptables -A FORWARD  -m state --state RELATED,ESTABLISHED -j ACCEPT	
#	iptables -A FORWARD  -i eth0 -s 192.168.1.0/24 -j ACCEPT
}

function deleteAllForwardRules() {

	iptables -t filter -F FORWARD
#	iptables -L FORWARD  --line-numbers | tail -1 | awk '{print $1}' | perl -ane '{
#		for(my $i=$F[0];$i>=1;$i--) {
#			system("iptables -t filter -D FORWARD $i");
#		};
#        }'

}

function addMacUsersPass() {

	cat /usr/local/yunwei/bin/macAdress.txt |  perl -ane 'if($_!~/^$/ && $_!~/^#/){
				
		system("iptables -A FORWARD -m mac --mac-source $F[0] -j ACCEPT");

        }'

}


function addRoute() {

	route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.40.249  2>/dev/null

}

function main() {

	exportPath
	deleteAllForwardRules
	letSetRulesAccess
	addMacUsersPass
	addRoute

}

	main
