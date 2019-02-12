#!/bin/bash
#Script de sauvegarde (complète et incrémentale)
#Réalisé 09/02/19 Par Numa BALARD
#Réaliser tous les jours une sauvegarde incrémental et une sauvegarde complète tous les mois
#Vérifie si les documents on été modifié
#Notifie l'utilisateur sur l'état des backups

#Variable
FILE1=/home/numa/Sauvegarde/FichiersDeReference/Fichier1		#Fichier modifier
FILE2=/home/numa/Sauvegarde/FichiersSauvegardes/$SAVE			#Fichier reference
SAVE=/home/numa/Sauvegarde/FichiersSauvegardes				#Fichier sauvegarder
DATE=`date +'%d-%m-%H-%M-%S'`						#Date du fichier

#Sauvegarde incrémentale
if ! diff $FILE2 $FILE1
	then
	echo "La sauvegarde va être effectuer"
	tar -cvzf $SAVE/sauvegarde_incremental_$DATE.tar $FILE1
	echo "La sauvegarde a été faite"
	cat $FILE2 >> $FILE1
	else
	echo "Pas de modification"
#	echo -e "Un mail va être envoyer car sa na pas sauvegarder" | mail -s "Mail envoyé" http@localhost
fi

#Suprresion des fichiers passé
find $SAVE -type f -mtime +180 -exec /bin/rm -f {} \;


