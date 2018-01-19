#!/bin/bash


function rebootOpenvpn() {

	/usr/bin/nohup /usr/sbin/openvpn /etc/openvpn/clien_sepj.ovpn >/dev/null &

}

function killAllOpenvpnProcess() {

	ps -ef | grep -i openvpn | grep -v grep | awk '{print $2}' | xargs kill -9

}

function setOpenvpnRout() {

	/root/bin/openVpnRoutSet.bash

}

function addGateWay() {

	echo "nameserver 114.114.114.114" > /etc/resolv.conf
	route add default gw 192.168.40.1 dev eth0

}

function main() {

	killAllOpenvpnProcess
	addGateWay
	sleep 2
	rebootOpenvpn
	sleep 15
	setOpenvpnRout
}

	main
