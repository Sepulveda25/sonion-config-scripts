#!/bin/bash

# Check if the script is being run with root priveleges
[ "$(id -u)" -ne 0 ] && printf "This script must be run using sudo!\n" && exit 1

# Check if [interface] is an empty string
if [[ -z $1 ]]; then
	printf "Usage: $0 [interface]\n"
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

printf "==| Ejecutando affinitySet.sh ..\n"
./affinitySet.sh $1 ./configFiles/suricata_affinity.yaml ./configFiles/bro_node.cfg_interfaceAffinity.txt

printf "\n==| Ejecutando miscConfig.sh ..\n"
./miscConfig.sh $1 ./configFiles/sysctl.conf ./configFiles/classification.config

printf "\n==| Ejecutando telegrafSetup.sh ..\n"
./telegrafSetup.sh ./configFiles/telegraf.conf

printf "\n==| Fin de configuracion, reinicia para aplicar los cambios.\n"
