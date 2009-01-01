#!/bin/sh 
# 
# Shell script to setup Adhoc networking on Wifi 
# 

modprobe ath_pci countrycode=826 autocreate=none
wlanconfig ath0 destroy
wlanconfig ath0 create wlandev wifi0 wlanmode adhoc
iwconfig ath0 essid giggi
iwconfig ath0 channel auto
ifconfig ath0 up

zcip -f -q ath0 /etc/zcip.script
