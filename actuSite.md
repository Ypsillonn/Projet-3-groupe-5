# Explication du script actuSite.sh

Ce script à pour but d'actualiser lu site de supervision à partir des fichiers .csv générés par les scripts infoCarno.sh et recupIP.sh

### Les varibles

    MON_FICHIER1=/home/albos/Scriptdir/leslogs.csv
    MON_FICHIER2=/home/albos/Scriptdir/esclave.csv
    MON_SITE=/home/albos/Scriptdir/monSite.html
    ERREUR=/home/albos/Scriptdir/erreur.log
    RECUP=$(grep -oP "\/.*" $ERREUR)
 
On créé des variables contenant les chemins des deux fichiers .csv pour pouvoir les afficher dans le site html  créé par 'MON_SITE' par 
la suite ainsi que deux autres variables, 'ERREUR' créant un fichier log d'erreurs et 'RECUP' récupérant uniquement le message d'erreur
dans le fichier 'erreur.log'.

### Suppression du site 

    echo "" > $MON_SITE
    
On supprime le site affin pour pouvoir le 'refresh' totalement et réécrire toute les nouvelles informations sans encombres.

## Création du site

        echo "<body background="/home/albos/Scriptdir/fond.jpeg">" >> $MON_SITE
        echo "<FONT size="4pt" face="Times New Roman"><B>Bienvenue sur le site de supervision, vous pouvez trouver <br> des 
        informations sur :</B> <ul> <li> <I>Les IPs\s'&eacute;tant connect&eacute;es au site carnofluxe </li> <br> <li>
        L'&eacute;tat des sites et les informations relative a la connection</I> </li> </ul> </FONT> <br>" >> $MON_SITE
        
 On créé 
