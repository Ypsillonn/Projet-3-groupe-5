# Explication du script recupIP.sh

Ce script permet la récupération des IPs dans le fichier log d'Apache2 et sera executé toute les heures via crontab depuis le serveur
HTTP

### Les variables

	FICHIER_LOG=/var/log/apache2/other_vhosts_access.log
	FICHIER_RECUP=/home/albos/Scriptdir/leslogs.csv

Les Variables 'FICHIER_LOG' et 'FICHIER_RECUP' vont prendre pour valeur des chemins de fichiers, 
cela nous permet d'y réacceder dans le code plus tard, sans avoir à retapper tout le chemin, pour le chemin 'FICHIER_RECUP'
il est à noté qu'il nous permet de créer le fichier 'leslogs.csv' (dans le cas ou un fichier n'existe pas si on ecrit un chemin
et que l'on rajoute un nouveau nom de fichier à la fin cela va créer un fichier de ce nom dès lors que l'on auras utilisé 
le chemin pour ecrire dans le fichier.).

### La recherche des IP et des dates de connexion

	grep -oP "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3} "
	grep -oP "\d{2}\/.+\:\d{2} "
	
La commande 'grep' est une commande permettant de chercher, dans un fichier ou autre chose (ex: ligne, fichier, etc...), 
un argument contenu dans ces derniers. Ici couplé à une option -oP nous permet d'une part (par l'option -o) de se focaliser sur les
expressions non vide, c'est à dire seulement où il y a du texte, et d'une autre part (par l'option -P) de définir l'argument que l'on 
va chercher comment étant noté sous la forme d'une expression régulière. La partie entre guillemets est donc notre expression régulière,
celle-ci nous permet de récuperer pour la première les IP, le '\d' nous permet de lire tout les chiffres (de 0 à 9) puis '{1,3}'
permet dedire que l'on veut une séquance de 3 chiffres à la suite suivit de '\.' qui permet de dire que l'on veut un point
après ces trois chiffres (l'antislash permet "d'échaper" le '.' qui à normalement une signification particulière dans 
les expressions régulières.) et ainsi de suite. La deuxième expression régulière permet de récupérer la date de forme
'14/Feb/19:10:35:42' pour ce faire le '\d{2}' qui à la même utilitée que précédement suivit d'un '/' puis '.+' qui sert à prendre tout
les caractère tant qu'il y en a jusqu'à ':' puis on réutilise '\d{2}'.

### Ecritures des IP et Dates dans le fichier .csv

	while read line

		do
			IP=echo $line | grep -oP "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
			DATE=echo $line | grep -oP "\d{2}\/.+\:\d{2}"
			echo "$IP;$DATE" >> $FICHIER_RECUP


		done < $FICHIER_LOG
		
On vient lire chaque lignes du fichier du chemin 'FICHIER_LOG' (on le voit a la fin au niveau du 'done') grace à 'read' et le while nous
sert à le faire tant qu'il reste des lignes. une fois ses lignes lue on les affichent une par une pour pouvoir s'en servir comme base
pour nos commandes 'grep' précédement citées et donc y récupérer les IP et Dates puis grâce à 'echo "$IP;$DATE" >> $FICHIER_RECUP' on les
ecrit dans le chemin contenue dans 'FICHIER_RECUP' sois dans le fichier leslogs.csv qui est donc créer.

### Suppression du fichier de log

	echo  "" > $FICHIER_LOG

On ecrit "rien" dans le fichier de log afin de 'reset' les adresses et les dates s'y trouvant pour pouvoir n'avoir que les nouvelles de la prochaine execution du script (A savoir que le script s'executera toute les heures par la suite.).
