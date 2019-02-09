#!/bin/bash

PING_LOG=/home/corentin/Documents/ping_log
DNS_LOG=/home/corentin/Documents/dns_log
DNS_LOG2=/home/corentin/Documents/dns_log2
PING_SITE=/home/corentin/Documents/ping_site
PING_SITE2=/home/corentin/Documents/ping_site2
CSV=/home/corentin/Documents/esclave.csv

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
elif [ "$(echo $pinghttptmp | head -n 9 | tail -n 1 | cut -d ',' -f 3)" != " 0% packet loss" ]
then
	etatsite="Partiellement fonctionnel"
	pinghttp=$pinghttp"ms"
else
	etatsite="Fonctionnel"
	pinghttp=$pinghttp"ms"
fi

echo "$(nslookup www.carnofluxe.local)" > $DNS_LOG

if [ "$(tail -n 1 $DNS_LOG)" = "** server can't find www.carnofluxe.local: NXDOMAIN" ]
then
	etatdns="Non-fonctionnel"
	pingsite="-"
elif [ "$(head -n 1 $DNS_LOG)" = ";; connection timed out; no servers could be reached" ]
then
	etatdns="Innaccessible"
	pingsite="-"
else
	etatdns="Fonctionnel"

fi

echo "$(nslookup supervision.carnofluxe.local)" > $DNS_LOG2

if [ "$(tail -n 1 $DNS_LOG2)" = "** server can't find supervision.carnofluxe.local: NXDOMAIN" ]
then
        etatdns2="Non-fonctionnel"
	pingsite2="-"
elif [ "$(head -n 1 $DNS_LOG2)" = ";; connection timed out; no servers could be reached" ]
then
        etatdns2="Innaccessible"
	pingsite2="-"
else
        etatdns2="Fonctionnel"
fi

printf "Site,Etat résolution DNS,Ping du serveur,Accessibilité du site,Temps de réponse de la page d'accueil\n" > $CSV
printf "www.carnofluxe.local,$etatdns,$pinghttp,$etatsite,$pingsite\n" >> $CSV
printf "supervision.carnofluxe.local,$etatdns2,$pinghttp,$etatsite,$pingsite2" >> $CSV