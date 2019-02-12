# Explication du script du serveur DNS esclave.

### Avant toute chose il est nécessaire de rappeller le but de ce script; ce dernier doit récupérer des informations concernant le site internet : accessibilité, ping, état de la résolution DNS et temps de réponse de la page d'acceuil. De plus il devra réunir ces données dans un fichier CSV et envoyer ce dernier, par SSH, au serveur HTTP.

### Maintenant on peut débuter l'explication :
 |
 

		#!/bin/bash

Ici on début le script en indiquant le programme avec lequel interpréter le script, ici le shell bash.
|

		PING_LOG=/home/anthony/Scriptdir/ping_log
		DNS_LOG=/home/anthony/Scriptdir/dns_log
		DNS_LOG2=/home/anthony/Scriptdir/dns_log2
		PING_SITE=/home/anthony/Scriptdir/ping_site
		PING_SITE2=/home/anthony/Scriptdir/ping_site2
		CSV=/home/anthony/Scriptdir/esclave.csv

On définit des variables correspondants aux chemins d'accés des différents fichiers nécessaires, pour ne pas avoir à les réécrire à chaque fois.
|

		{ time wget -pq --no-cache --delete-after www.carnofluxe.local ; } 2> $PING_SITE

		pingsite=$(head -n 2 $PING_SITE | tail -n 1 | cut -c 6-15 | tr ',' '.')

		{ time wget -pq --no-cache --delete-after supervision.carnofluxe.local ; } 2> $PING_SITE2

		pingsite2=$(head -n 2 $PING_SITE2 | tail -n 1 | cut -c 6-15 | tr ',' '.')

On récupère le temps de réponse de la page d'acceuil des 2 sites et on les attribue aux variables pingsite et pingsite2, respectivement le site de ecommerce et celui de supervision. On redire également les erreurs potentielles vers des fichiers, pour que l'administateur puisse les voir.
|
		
		pinghttp=$(ping -c 5 192.168.10.10 | tee $PING_LOG | tail -n 1 | cut -d '/' -f 5)
		
		pinghttptmp=$(<$PING_LOG)

		if [ "$pinghttp" = "" ]
		then
			pinghttp="-"
			etatsite="Non-fonctionnel"
			pingsite="-"
			pingsite2="-"
			echo "" | mail -s "Erreur lors du ping du serveur HTTP." -A $PING_LOG -- anthony
		elif [ "$(echo $pinghttptmp | head -n 9 | tail -n 1 | cut -d ',' -f 3)" != " 0% packet loss" ]
		then
			etatsite="Partiellement fonctionnel"
			pinghttp=$pinghttp"ms"
			echo "" | mail -s "Erreur lors du ping du serveur HTTP." -A $PING_LOG -- anthony
		else
			etatsite="Fonctionnel"
			pinghttp=$pinghttp"ms"
		fi
		
-On teste le ping du serveur HTTP 5 fois et on récupère la moyenne de la latence, qu'on attribue à la variable pinghttp et on enregistre l'intégralité de la sortie de la commande dans un fichier, à nouveau pour l'administrateur en cas d'erreur.
-Si aucune latence moyenne n'est trouvée c'est que le serveur est inaccessible; dans ce cas on remplace la moyenne de la latence par un tiret, de même pour le temps de réponse des pages d'accueil., et on inscrit "Non-fonctionnel" dans la variable etatsite. Enfin on envoie un e-mail à l'administrateur avec en fichier joint le fichier contenant l'intégralité de la sortie de la commande.
-Si une latence moyenne est trouvée, mais si il y a également un pourcentage de paquets perdus supérieurs à 0%, on rajoute ms (pour milli seconde) à la fin de la variable pinghttp; on envoie également le fichier à l'administrateur par e-mail, et on attribue "Partiellement fonctionnel" à la variable etatsite.
-Enfin si aucune erreur n'a eu lieu, on ajoute là aussi ms à la variable pinghttp, et on attribue "Fonctionnel" à la variable etatsite?
|

		echo "$(nslookup www.carnofluxe.local)" > $DNS_LOG
		
		if [ "$(tail -n 1 $DNS_LOG)" = "** server can't find www.carnofluxe.local: NXDOMAIN" ]
		then
			etatdns="Non-fonctionnel"
			pingsite="-"
			echo "" | mail -s "Erreur lors du ping de la résolution DNS." -A $DNS_LOG -- anthony
		elif [ "$(head -n 1 $DNS_LOG)" = ";; connection timed out; no servers could be reached" ]
		then
			etatdns="Inaccessible"
			pingsite="-"
			echo "" | mail -s "Erreur lors du ping de la résolution DNS." -A $DNS_LOG -- anthony
		else
			etatdns="Fonctionnel"
		fi

-On teste la résolution de nom du site "www.carnofluxe.local" et on écrit la sortie dans un fichier.
-Si la sortie de la commande contient "** server can't find www.carnofluxe.local: NXDOMAIN", on attribue "Non-fonctionnel" à la variable etatdns, on attribue un tiret à la variable pingsite, et on envoie le fichier à l'adminsitrateur par e-mail.
-Si la sortie de la commande contient ";; connection timed out; no servers could be reached", on attribue "Inaccessible" à la variable etatdns, on attribue un tiret à la variable pingsite, et on envoie le fichier à l'adminsitrateur par e-mail.
-Sinon, on attribue simplement "Fonctionnel" à la variable etatdns.
|

		echo "$(nslookup supervision.carnofluxe.local)" > $DNS_LOG2

		if [ "$(tail -n 1 $DNS_LOG2)" = "** server can't find supervision.carnofluxe.local: NXDOMAIN" ]
		then
		        etatdns2="Non-fonctionnel"
			pingsite2="-"
			echo "" | mail -s "Erreur lors du ping de la résolution DNS." -A $DNS_LOG2 -- anthony 
		elif [ "$(head -n 1 $DNS_LOG2)" = ";; connection timed out; no servers could be reached" ]
		then
		        etatdns2="Innaccessible"
			pingsite2="-"
			echo "" | mail -s "Erreur lors du ping de la résolution DNS." -A $DNS_LOG2 -- anthony
		else
		        etatdns2="Fonctionnel"
		fi

Ce bloc est très semblable au précédent dans la mesure ou seuls l'url du site (supervision.carnofluxe.local) et les variable (etatdsn2 et pingsite2) changent.
|
		echo "www.carnofluxe.local,$etatdns,$pinghttp,$etatsite,$pingsite\n" > $CSV
		echo "supervision.carnofluxe.local,$etatdns2,$pinghttp,$etatsite,$pingsite2" >> $CSV

On écrit dans le fichier CSV les contenus des variables.
|
		if [ "$pinghttp" != "-" ]

		then
			scp -o ConnectTimeout=30 $CSV anthony@192.168.10.10:/home/anthony/Scriptdir ;
		else
			echo "Le serveur HTTP n'étant pas accessible le fichier CSV n'a pas été transféré." | mail -s "Connection SSH impossible." anthony
		fi

Si le serveur http n'était pas accessible, on envoie un mail à l'administarteur pour lui indiquer que le transfert SSH n'a pas pu être effectué. Sinon on tranfert le fichier CSV par SSH au serveur HTTP.


### Ce script sera exécuté toutes les heures sur le serveur du DNS esclave via la commande : 
### crontab 0 * * * * /chemin/du/script.sh
