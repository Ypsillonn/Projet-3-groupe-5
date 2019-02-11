#!/bin/bash

#=====================================================================================
#
# Cesi EXIA A1
# 07/02/2019
# Réalisation : Clément Albos
#
# Scrit d'actualisation du site de supervision à partir des fichiers .csv
#
# Sur le serveur HTTP, un script sera exécuté toutes les 5 minutes pour régénérer
# la ou les pages WEB du site de supervision à partir des fichiers CSV.
# En cas de problème d’accès aux fichiers CSV, la page générée doit indiquer l’erreur.
#
#=====================================================================================


MON_FICHIER1=/home/albos/Scriptdir/leslogs.csv
MON_FICHIER2=/home/albos/Scriptdir/esclave.csv
MON_SITE=/home/albos/Scriptdir/monSite.html
ERREUR=/home/albos/Scriptdir/erreur.log
RECUP=$(grep -oP "\/.*" $ERREUR)
echo "" > $MON_SITE

if [[ -f "$MON_FICHIER1" && "$MON_FICHIER2" ]];then

echo "<body background="/home/albos/Scriptdir/fond.jpeg">" >> $MON_SITE
echo "<FONT size="4pt" face="Times New Roman"><B>Bienvenue sur le site de supervision, vous pouvez trouver <br> des informations sur :</B> <ul> <li> <I>Les IPs\
 s'&eacute;tant connect&eacute;es au site carnofluxe </li> <br> <li>L'&eacute;tat des sites et les informations relative a la connection</I> </li> </ul> </FONT> <br>" >> $MON_SITE

echo "<table border="2" cellpadding="10" cellspacing="1" width="50%">" >> $MON_SITE

echo "<caption><B><I><U>IP s'&eacute;tants connect&eacute;es (dat&eacute;es)</U></I></B></caption>" >> $MON_SITE
echo "<thead>" >> $MON_SITE
echo "<tr> <th>Adresse IP : </th> <th>Date : </th> </tr>" >> $MON_SITE
echo "</thead>" >> $MON_SITE

while read line

	do
		echo $line | awk -F ";" '{print  "<tr>" "<td>" $1 "</td>" "<td>" $2 "</td>" "</tr>" }' >> $MON_SITE


	done < $MON_FICHIER1

echo "</table>" >> $MON_SITE

echo "<br>" >> $MON_SITE

echo "<table border="2" cellpadding="10" cellspacing="1" width="100%">" >> $MON_SITE
echo "<caption><B><I><U>Informations concernant l'&eacute;tat du site</U></I></B></caption>" >> $MON_SITE
echo "<thead>" >> $MON_SITE
echo "<tr> <th> Site </th> <th> Etat r&eacute;solution DNS </th> <th> Ping du serveur </th><th> Accessibilit&eacute; du site </th> <th> Temps de reponse de la page d'accueil </th></tr>" >> $MON_SITE
while read line

       do
		echo $line | awk -F "," '{print  "<tr>"   "<td>" $1 "</td>" "<td>" $2 "</td>" "<td>" $3 "</td>" "<td>" $4 "</td>" "<td>" $5 "</td>" "</tr>"}' >> $MON_SITE

       done < $MON_FICHIER2

echo "</table>" >> $MON_SITE
echo "Ecriture du site faite !"

else

	echo "Fichiers .csv introuvables"
	$MON_FICIER1 2>> $ERREUR
	#chmod 755 $ERREUR
	$MON_FICHIER2 2>> $ERREUR
	echo $RECUP >> $MON_SITE
fi
#sudo systemctl restart apache2
