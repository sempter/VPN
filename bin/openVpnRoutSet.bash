#!/bin/bash

/sbin/route del -net 0.0.0.0 netmask 128.0.0.0
/sbin/route del -net 128.0.0.0 netmask 128.0.0.0
/sbin/route add -net 10.0.0.0  netmask 255.0.0.0 gw 10.8.0.173
/sbin/route add -net 100.0.0.0 netmask 255.0.0.0 gw 10.8.0.173

/sbin/route -n

