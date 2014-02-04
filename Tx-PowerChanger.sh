#!/bin/bash
#script by Luke for changing Tx-Power
clear

STD=$(echo -e "\e[0m")        	#Standart
BLU=$(echo -e "\e[1;34m")		#Blue
CYA=$(echo -e "\e[1;36m")		#Cyan
GRA=$(echo -e "\e[1;30m")		#Gray
GRN=$(echo -e "\e[1;32m")		#Green
PUR=$(echo -e "\e[1;35m")		#Purple
RED=$(echo -e "\e[1;31m")		#Red
WHI=$(echo -e "\e[1;37m")		#White
YEL=$(echo -e "\e[1;33m")		#Yellow

c_c(){
	if [ "$INTERFACE" != "" ]; then
	echo -e "$RED""\n\nReturning changes to default values.\nDon't exit! \nI will exit automatically.\n $STD"
		ifconfig $INTERFACE down
		ifconfig $INTERFACE hw ether $ORIGINAL_MAC
		iw reg set $ORIGINAL_COUNTRY
		ifconfig $INTERFACE up
		iwconfig $INTERFACE txpower $ORIGINAL_TX
		iwconfig $INTERFACE channel $ORIGINAL_CHANNEL
		exit 
	else
		echo 
		echo $STD
		exit
	fi }

set_tx(){
	read -p "$BLU""Set Tx-power for $CYA$INTERFACE $GRA(16[min]-30[max]) : $WHI" tx
	if [[ "$tx" < "16" || "$tx" > "30" || "$tx" == "" ]]; then
		echo -e "$RED""Wrong value! Try again.\n"
		set_tx
	else
		echo "$GRN""Changing Tx-power from $ORIGINAL_TX dBm to $tx dBm"
		iwconfig $INTERFACE txpower $tx
	fi }

start(){
	echo "$YEL""Available wireless interfaces:$PUR "
	int=$(ifconfig | grep wlan | cut -c 1-5)
	echo "$int"
	read -p "$BLU""Set your interface:$WHI " INTERFACE
	if [ ! -z $(echo $INTERFACE | grep "$int") ]; then
							#Values before changes#
		ORIGINAL_MAC=$(ifconfig $INTERFACE | grep HW | cut -d "r" -f3)
		ORIGINAL_TX=$(iwconfig $INTERFACE | grep Power= | cut -d "=" -f2 | cut -c 1-2)
		ORIGINAL_COUNTRY=$(iw reg get | grep : | cut -d ":" -f1 | cut -d " " -f2)
		ORIGINAL_CHANNEL=$(iwlist wlan0 channel | grep Current | cut -d "l" -f2 | cut -d ")" -f1)
							#######################
		echo "$GRN""Shutting down $CYA$INTERFACE"
		ifconfig $INTERFACE down
		read -p "$BLU""Do you want to change MAC address?$GRA (Y/n) $WHI" ans
		if [[ "$ans" == "Y" || "$ans" == "y" || "$ans" == "" ]]; then
			macchanger -a $INTERFACE
			echo "$GRN""Changing MAC"
		else
			echo "$GRN""Not changing MAC"
		fi
		echo "$GRN""Changing $ORIGINAL_COUNTRY (actual) country to BO (Bolivia)"
		iw reg set BO
		echo "$GRN""Turning on $CYA$INTERFACE"
		ifconfig $INTERFACE up
		echo "$GRN""Setting up channel 13"
		iwconfig $INTERFACE channel 13
		set_tx
		echo -e "$BLU""Sucessfully done! Happy Hacking! \n $STD" 
	else
		echo -e "$RED""Wrong interface name! Try again.\n $STD"
		INTERFACE=""
		sleep 1
		clear
		start
	fi }
trap c_c 2
start