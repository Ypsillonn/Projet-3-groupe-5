# Explication du script actuSite.sh

### Les varibles

    MON_FICHIER1=/home/albos/Scriptdir/leslogs.csv
    MON_FICHIER2=/home/albos/Scriptdir/esclave.csv
    MON_SITE=/home/albos/Scriptdir/monSite.html
    ERREUR=/home/albos/Scriptdir/erreur.log
    RECUP=$(grep -oP "\/.*" $ERREUR)

