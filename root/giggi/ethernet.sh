#!/bin/sh 
# 
# Shell script to setup Ethernet 
# 

# Load kernel module 
modprobe via-rhine 
ifconfig eth0 up 

# Now start DHCP 
udhcpc -i eth0 -c semradio -s /etc/udhcp.script -p /var/udhcpc.pid 

# Start a telnet server 
telnetd 

# And set the system clock 
rdate time.aelius.com 
