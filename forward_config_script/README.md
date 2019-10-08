# Configuracion de un nodo Forward

## Contenido
+ Archivo general de configuracion de Security Onion (*sosetup_forward.conf*) para un servidor de tipo "forward" con 16 GB RAM y 8 nucleos de CPU que monitoreara un trafico sostenido promedio de 250Mb.
+ Script de configuracion de afinidad de CPU (*affinitySet.sh*).
+ Script de configuracion de balanceo de carga, cache de linux y reglas de clasificacion de alertas IDS (*miscConfig.sh*).
+ Script de configuracion de telegraf (*telegrafSetup.sh*).
+ Archivos de configuracion para lo anterior en *configFiles/*.

## Instrucciones

### Configuracion de Security Onion
1. Revisar el archivo de configuracion *sosetup_forward.conf* para asegurar que esten bien todos los campos.
2. Iniciar el setup:  
`sudo sosetup -f sosetup_forward.conf`
3. Autenticarse con el servidor master (clave ssh) 3 veces durante la instalacion, una vez explicita y dos veces cuando se detiene el script por un tiempo.

### Configuracion de afinidad de CPU, telegraf y miscelaneo
Este script configura la afinidad de CPU, el balancedor de carga, el cache de linux y las reglas de clasificacion de alertas IDS.  
Ejecuta a los scripts *affinitySet.sh*, *miscConfig.sh* y *telegrafSetup.sh* pasando como parametro los archivos adecuados en la carpeta *configFiles/*.
1. Revisar los archivos de configuracion en *configFiles/*.
2. Asegurar que el script *config.sh* es ejecutable y ejecutalo con los parametros y permisos adecuados*:  
`sudo ./setup.sh [interface]`

\* La interfaz debe ser la del sensor configurado en la seccion Configuracion de Security Onion

---

### Configuraciones Individuales

#### Afinidad de CPU

###### Cambios
Netsniff-ng es asignado al CPU0.  
Por defecto suricata tiene un management thread en CPU1 y tres worker threads en CPU[2-4].  
Por defecto bro tiene tres threads en CPU[5-7].

##### Setup
1. Revisar los archivos de configuracion en *configFiles/*.
2. Asegurar que el script *affinitySet.sh* es ejecutable y ejecutalo con los parametros y permisos adecuados:  
`sudo ./affinitySet.sh [interface] [suricata_affinity_file] [bro_affinity_file]`

#### Miscelaneas

###### Balanceo de carga
El balanceador de carga es seteado a pfring (siendo af-packet la alternativa).
###### Cache de linux
Se configuran estas variables en */etc/sysctl.conf* :
* vm.dirty_background_ratio = 50
* vm.dirty_ratio = 80
* vm.swappiness = 10
###### Reglas de clasificacion de alertas IDS
Se copian las reglas de clasificacion de alertas IDS a */etc/nsm/rules/classification.config*

##### Setup
1. Revisar los archivos de configuracion en *configFiles/*.
2. Asegurar que el script *miscConfig.sh* es ejecutable y ejecutalo con los parametros y permisos adecuados:  
`sudo ./miscConfig.sh [interface] [sysctl_config_file] [ids_classification_file]`

#### Telegraf
Se instala y se configura Telegraf para recopilar e informar métricas a un servidor de Grafana

##### Setup
1. Revisar el archivo de configuracion en *configFiles/telegraf.conf*. 
2. Asegurar que el script *telegrafSetup.sh* es ejecutable y ejecutalo con los parametros y permisos adecuados:  
`sudo ./telegrafSetup.sh [telegraf_config_file]`

###### Directorio de configuracion
Hasta la version 1.12.1 de Telegraf el archivo de configuracion telegraf.conf se encuetra en /etc/telegraf por defecto, tener esto en cuenta para
futuras versiones.

##  Referencias
+ https://suricata.readthedocs.io/en/latest/configuration/suricata-yaml.html#threading
+ https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/
+ https://www.sans.org/reading-room/whitepapers/detection/configuring-security-onion-detect-prevent-web-application-attacks-33980
+ https://suricata.readthedocs.io/en/suricata-4.1.4/rules/meta.html
+ https://docs.influxdata.com/telegraf/v1.11/introduction/installation/
