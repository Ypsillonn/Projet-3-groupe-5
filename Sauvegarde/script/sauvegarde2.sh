#!/bin/bash
#Script de sauvegarde (complète et incrémentale)
#Réalisé 09/02/19 Par Numa BALARD
#Réaliser tous les jours une sauvegarde incrémental et une sauvegarde complète tous les mois
#Vérifie si les documents on été modifié
#Notifie l'utilisateur sur l'état des backups

#Variable
FILE1=/home/numa/Sauvegarde/FichiersDeReference/Fichier1		#Fichier modifier
FILE2=/home/numa/Sauvegarde/FichiersDeReference/Fichier2		#Fichier de reference
SAVE=/home/numa/Sauvegarde/FichiersSauvegardes				#Fichier sauvegarder
DATE=`date +'%d-%m-%H-%M-%S'`						#Fichier dater

#Sauvegarde compléte
echo "La sauvegarde va être effectuer"
tar -cvzf $SAVE/sauvegarde_complete_$DATE.tar $FILE2
echo "La sauvegarde a été faite"

