#!/bin/bash

PING_LOG=/home/anthony/Scriptdir/ping_log
DNS_LOG=/home/anthony/Scriptdir/dns_log
DNS_LOG2=/home/anthony/Scriptdir/dns_log2
PING_SITE=/home/anthony/Scriptdir/ping_site
PING_SITE2=/home/anthony/Scriptdir/ping_site2
CSV=/home/anthony/Scriptdir/esclave.csv

pinghttp=$(ping -c 5 192.168.10.10 | tee $PING_LOG | tail -n 1 | cut -d '/' -f 5)

pinghttptmp=$(<$PING_LOG)

{ time wget -pq --no-cache --delete-after www.carnofluxe.local ; } 2> $PING_SITE

pingsite=$(head -n 2 $PING_SITE | tail -n 1 | cut -c 6-15 | tr ',' '.')

{ time wget -pq --no-cache --delete-after supervision.carnofluxe.local ; } 2> $PING_SITE2

pingsite2=$(head -n 2 $PING_SITE2 | tail -n 1 | cut -c 6-15 | tr ',' '.')



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

echo "$(nslookup supervision.carnofluxe.local)" > $DNS_LOG2

if [ "$(tail -n 1 $DNS_LOG2)" = "** server can't find supervision.carnofluxe.local: NXDOMAIN" ]
then
        etatdns2="Non-fonctionnel"
	pingsite2="-"
	echo "" | mail -s "Erreur lors du ping de la résolution DNS." -A $DNS_LOG2 -- anthony 
elif [ "$(head -n 1 $DNS_LOG2)" = ";; connection timed out; no servers could be reached" ]
then
        etatdns2="Inaccessible"
	pingsite2="-"
	echo "" | mail -s "Erreur lors du ping de la résolution DNS." -A $DNS_LOG2 -- anthony
else
        etatdns2="Fonctionnel"
fi

echo "www.carnofluxe.local,$etatdns,$pinghttp,$etatsite,$pingsite\n" > $CSV
echo "supervision.carnofluxe.local,$etatdns2,$pinghttp,$etatsite,$pingsite2" >> $CSV

if [ "$pinghttp" != "-" ]

then
	scp -o ConnectTimeout=30 $CSV anthony@192.168.10.10:/home/anthony/Scriptdir ;
else
	echo "Le serveur HTTP n'étant pas accessible le fichier CSV n'a pas été transféré." | mail -s "Connection SSH impossible." anthony
fi
