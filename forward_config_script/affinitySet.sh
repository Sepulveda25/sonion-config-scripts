#!/bin/bash

# Check if the script is being run with root priveleges
[ "$(id -u)" -ne 0 ] && printf "This script must be run using sudo!\n" && exit 1

# Check if [interface] is an empty string
if [[ -z $1 ]]; then
	printf "Usage: $0 [interface] [suricata_affinity_file] [bro_affinity_file]\n"
	exit 1
fi

# Check if [suricata_affinity_file] file does not exist, or is empty
if [[ ! -s $2 ]]; then 
	printf "Usage: $0 [interface] [suricata_affinity_file] [bro_affinity_file]\n"
	exit 1
fi

# Check if [bro_affinity_file] file does not exist, or is empty
if [[ ! -s $3 ]]; then 
	printf "Usage: $0 [interface] [suricata_affinity_file] [bro_affinity_file]\n"
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

# Copy the content of [suricata_affinity_file] to the CPU affinity section of
#  "/etc/nsm/$(cat /proc/sys/kernel/hostname)-$1/suricata.yaml"
printf "Configurando afinidad en /etc/nsm/$(cat /proc/sys/kernel/hostname)-$1/suricata.yaml ..\n"
sed -i "/^# Suricata is multi-threaded./,/  detect-thread-ratio: 1.0/{
    R $2
    d
  }" /etc/nsm/$(cat /proc/sys/kernel/hostname)-$1/suricata.yaml

# Copy the content of [bro_affinity_file] to the CPU affinity section of
#  "/opt/bro/etc/node.cfg"
printf "Configurando afinidad en /opt/bro/etc/node.cfg ..\n"
# sed -i "/^lb_procs/ R $3" ./node.cfg
if grep --regexp="^pin_cpus" /opt/bro/etc/node.cfg --quiet; then
	echo trueeeeeeeeeeeeee
	sed -i "/^pin_cpus/{
		R $3
		d
	}" /opt/bro/etc/node.cfg
else
	echo falseeeeeeeeeeeeeeeeeeee
	sed -i "/^lb_procs/ R $3" /opt/bro/etc/node.cfg
fi
