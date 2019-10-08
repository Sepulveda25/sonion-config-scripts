#!/bin/bash

# Check if the script is being run with root priveleges
[ "$(id -u)" -ne 0 ] && printf "This script must be run using sudo!\n" && exit 1

# Check if [interface] is an empty string
if [[ -z $1 ]]; then
	printf "Usage: $0 [interface] [sysctl_config_file] [ids_classification_file]\n"
	exit 1
fi

# Check if [sysctl_config_file] file does not exist, or is empty
if [[ ! -s $2 ]]; then 
	printf "Usage: $0 [interface] [sysctl_config_file] [ids_classification_file]\n"
	exit 1
fi

# Check if [ids_classification_file] file does not exist, or is empty
if [[ ! -s $3 ]]; then 
	printf "Usage: $0 [interface] [sysctl_config_file] [ids_classification_file]\n"
	exit 1
fi

# Check if /sys/class/net/[interface]/carrier file does not exist, or is empty
if [[ ! -s /sys/class/net/$1/carrier ]]; then 
	printf "Interfaz \"$1\" no existe\n"
	exit 1
fi

# Check if /sys/class/net/[interface]/carrier file content is 0 (indicates that physical link is down)
if [[ $(cat /sys/class/net/$1/carrier) == "0" ]]; then 
	printf "El enlace fisico de la interfaz \"$1\" esta caido\n"
	exit 1
fi

# Set pfring as the load balancer (af-packet is the default)
printf "Configurando pfring en /etc/nsm/$(cat /proc/sys/kernel/hostname)-$1/sensor.conf ..\n"
sed -i 's/SURICATA_CAPTURE="af-packet"/SURICATA_CAPTURE="pfring"/' /etc/nsm/$(cat /proc/sys/kernel/hostname)-$1/sensor.conf

# Configure Linux Disk Caching
printf "Copiando configuracion de cache de linux a /etc/sysctl.conf y aplicando los nuevos valores ..\n"
cp $2 /etc/sysctl.conf
sysctl -p

# Set new classification rules for incoming IDS alerts
printf "Copiando reglas de clasificacion de alertas IDS a /etc/nsm/rules/classification.config ..\n"
cp $3 /etc/nsm/rules/classification.config

