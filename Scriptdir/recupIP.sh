#!/bin/bash

#=====================================================================================
# Cesi EXIA A1
# 07/02/2019
# Réalisation : Clément Albos
#
# Script permettant la récupération des IPs dans le fichier log d'Apache2
#
# Un script remontera toutes les heures dans un fichier au format CSV les adresses IP
# des clients s'étant connectés sur le site durant la dernière heure. Ces adresses
# seront récupérées dans les fichiers de log dApache.
#
#=====================================================================================

# Création d'une variable ayant pour valeur le chemin des logs Apache2
FICHIER_LOG=/var/log/apache2/other_vhosts_access.log

# Création d'une variable ayant pour valeur le chemin du dossier où on stock les IPs
FICHIER_RECUP=/home/albos/Scriptdir/leslogs.csv

# Suppression de l'ancien fichier de log
#rm $FICHIER_RECUP

# Tant que l'on peut lire une ligne dans le fichier on fait l action suivante
while read line

	do

# Création des variables IP et DATE à partir de la commande grep accompagnée d'une epression régulière

		IP=echo $line | grep -oP "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
		DATE=echo $line | grep -oP "\d{2}\/.+\:\d{2}"

# Ecriture des IPs récupérées et des DATES dans le fichier FICHIER_RECUP
		echo "$IP;$DATE" >> $FICHIER_RECUP

# Allocation du fichier LOG en temps que parametre de la boucle
	done < $FICHIER_LOG

# Suppression du contenu du fichier de LOG pour n'avoir que la prochaine heure de connection
echo  "" > $FICHIER_LOG
