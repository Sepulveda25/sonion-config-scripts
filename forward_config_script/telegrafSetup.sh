#!/bin/bash

# Check if the script is being run with root priveleges
[ "$(id -u)" -ne 0 ] && printf "This script must be run using sudo!\n" && exit 1


# Check if [PATH_telegraf.conf] is an empty string
if [[ -z $1 ]]; then
	printf "Usage: $0 [PATH_telegraf.conf]\n"
	exit 1
fi

# Chech if telegraf is installed
if ! command -v telegraf >/dev/null 2>&1; then
	echo "Agregando repositorio"
	wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
	source /etc/lsb-release
	echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	sudo apt-get update 
	echo "Instalando telegraf"
	apt-get install telegraf -y 
else
	echo "Telegraf ya instalado"
fi

if ! cmp --silent ./configFiles/telegraf.conf /etc/telegraf/telegraf.conf; then
	echo "Copiando configuracion"
	cp $1 /etc/telegraf/telegraf.conf
else
	echo "Configuracion ya copiado"
fi
echo "Reiniciando telegraf"
systemctl restart telegraf
