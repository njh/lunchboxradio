#!/bin/sh 
# 
# Shell script to setup DHCP on Ethernet 
# 

# Load kernel module 
modprobe via-rhine 
ifconfig eth0 up 

# Now start DHCP 
udhcpc -i eth0 -c giggi -s /etc/udhcpc.script -p /var/udhcpc.pid 

# And set the system clock 
rdate time.giggi.org
