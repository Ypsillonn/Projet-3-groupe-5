# Explication du script actuSite.sh

Ce script à pour but d'actualiser le site de supervision à partir des fichiers .csv générés par les scripts infoCarno.sh et recupIP.sh
ce script sera executé toute les 5 minutes via crontab depuis le serveur HTTP.

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

### Mise en page

    echo "<body background="/home/albos/Scriptdir/fond.jpeg">" >> $MON_SITE
    echo "<FONT size="4pt" face="Times New Roman"><B>Bienvenue sur le site de supervision, vous pouvez trouver <br> des 
    informations sur :</B> <ul> <li> <I>Les IPs\s'&eacute;tant connect&eacute;es au site carnofluxe </li> <br> <li>
    L'&eacute;tat des sites et les informations relative a la connection</I> </li> </ul> </FONT> <br>" >> $MON_SITE
        
On met grâce à la première commande un fond sur notre site ce qui vient d'emblé créer notre site. Ensuite on y ajoute un
message de bienvenue en gras et en 'Times New Roman' et qui d'affichera tout en haut du site.

### Mise en place de l'affichage des données .csv et des message d'erreur

    if [[ -f "$MON_FICHIER1" && "$MON_FICHIER2" ]];then

    echo "<body background="/home/albos/Scriptdir/fond.jpeg">" >> $MON_SITE
    echo "<FONT size="4pt" face="Times New Roman"><B>Bienvenue sur le site de supervision, vous pouvez trouver <br> des informations sur    :</B> <ul> <li> <I>Les IPs\
     s'&eacute;tant connect&eacute;es au site carnofluxe </li> <br> <li>L'&eacute;tat des sites et les informations relative a la       connection</I> </li> </ul> </FONT> <br>" >> $MON_SITE

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
    
On pose une condition concernant l'accessibbilité aux scripts, si on y à accès on :
- Fait la mise en page du site;
- On créé un premier tableau en y ajoutant un titre et en definissant la première ligne comme étant les titres des colone;
- On vien lire le fichier leslogs.csv où sont stockées les IPs et dates et on les met dans le tableau précédement créé dans leur colonne respectives;
- On termine enfin le tableau saute une ligne puis créé un deuxième tableau en y mettant comme le précédent un titre et des titres de colonnes;
- On y inclue les données située dans le fichier esclave.csv qui contient les données de connexions aux sites;
- On ferme le tableau et on affiche dans la console que l'écriture du site à été effectué.

        else

                echo "Fichiers .csv introuvables"
                $MON_FICIER1 2>> $ERREUR
                $MON_FICHIER2 2>> $ERREUR
                echo $RECUP >> $MON_SITE
        fi
Sinon, si l'on a pas les fichiers .csv :
- On dit à l'utilisateur que ceux-ci sont introuvables;
- On redirige le message d'erreur entier de l'accès au fichier leslogs.csv et celui de esclave.csv
- On marque sur le site les message d'erreur préalablement ecourtés (pour n'avoir que l'essentiel et pas la ligne du code etc...).

