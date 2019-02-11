# Procédures d’installation et de configuration des serveurs

Ce document renseigne les procédures d’installation et la configuration des serveurs pour pouvoir la reproduire.
Dans ce projet, nous avons utilisé des machines virtuelles pour « simuler » nos serveurs. Il est donc fort probable, que lors du déploiement physique, certaines procédures diffèrent un peu.
Le but de ce projet est de répondre à une demande de la société Carnofluxe, qui souhaite adapter son système d’information pour accueillir à terme un site de e-commerce avec des outils de supervision pour ce site.
C’est-à-dire : 	

-	La mise en place d’un service de résolution de nom en interne sur le domaine carnofluxe.domain. L’objectif est de permettre une gestion des noms d’hôtes sans adresse IP publique dans le réseau privé de l’entreprise.

-	La gestion des sauvegardes et des remontées d’informations pour assurer un support et une continuité de service de qualité qui sera faite grâce à des scripts bash sur les serveurs sous système d’exploitation GNU/Linux. 

-	La mise en place d’un serveur HTTP et la mise en ligne d’un site WEB supervision accessible uniquement depuis le réseau interne qui intégrera des données. (À terme le site de e-commerce sera déployé sur un serveur de production physiquement différent bien entendu) 

-	Une réflexion sur un plan de sauvegarde à mettre en place pour le serveur WEB. 

Pour répondre à cela, nous avons créé trois serveurs : 

-	« dns1 » : Serveur DNS maitre et DHCP | IP : 192.168.10.5/24

-	« dns2 » : Serveur DNS esclave | IP : 192.168.10.6/24

-	« serv_http » : Serveur apache | IP : 192.168.10.10/24

## Serveur DNS / DHCP 

### Pré-requis

Avant de configurer les deux services, il y a plusieurs étapes à effectuer. Pour commencer il faut définir un nom à notre machine : 
                    
    sudo su
    
On passe en root et ensuite on ouvre le fichier « hosts » :
	              
    nano /etc/hosts

Et on modifie la ligne 2 (127.0.1.1) il faut remplacer par son nom machine avec son nom de domaine "dns1.carnofluxe. local".
	    
    127.0.1.1         dns1.carnofluxe.local
    
On ouvre ensuite le fichier « hostname » :

    nano /etc/hostname
 
Et on modifie le nom par anthony-virtual-machine par « dns1 ».
 
    dns1
      
Et on redémarre la machine pour que les modifications soit prises en compte

    reboot
    
Une fois que la machine à redémarrer, il faut télécharger tout les paquets : 

    apt-get update && apt-get upgrade
    apt-get install bind9
    apt-get install isc-dhcp-server
    apt-get install openssh-server
    
 Une fois tout les packets installés correctement, il faut configurer une IP fixe à notre serveur.
 Pour cela on ouvre le fichier interfaces :

    nano /etc/network/interfaces
    
 Ensuite, on modifie la configuration en ajoutant les lignes suivantes : 

    auto ens33
    iface ens33 inet static
    address 192.168.10.5
    netmask 255.255.255.0
    gateway 192.168.10.2
    
 Pour finir, on redémarre pour que tout soit pris en compte.
 
     reboot
     
Nous avons maintenant fini avec les pré-requis pour ce serveur.

### DHCP

Nous allons passer à la configuration du DHCP.
Pour commencer, il faut ouvrir le fichier "dhcpd.conf" :

    nano /etc/dhcp/dhcpd.conf
    
Il faut commenter effacer toutes les lignes du fichier, et ensuite y ajouter les suivantes : 

    subnet 192.168.10.0 netmask 255.255.255.0{
                range 192.168.10.100 192.168.10.200;
                option domain-name "carnofluxe.domain";
                option routers 192.168.10.2;
                option broadcast-address 192.168.10.255;
                option domain-name-servers 192.168.10.5;
                default-lease-time 600;
                max-lease-time 7200;
      }
     
Il faut relancer le service DHCP pour prendre en compte la configuration :

    service isc-dhcp-server restart
    
Pour vérifier si le serveur marche bien, il faut taper la commande suivante :

     service isc-dhcp-server status
     
Nous en avons maintenant fini avec la configuration du DHCP.
    
### DNS Maître

On commence par ouvrir le fichier "named.conf.local" : 

    nano /etc/bind/named.conf.local
    
On modifie ensuite le fichier en y placant les lignes suivantes :

    zone "carnofluxe.local" IN {
        type master;
        allow-transfer { 192.168.10.6; };
        file "/etc/bind/db.carnofluxe.local";
    };

    zone "10.10.168.192.in-addr.arpa" IN {
        type master;
        allow-transfer { 192.168.10.6; };
        file "/etc/bind/db.10.10.168.192";
     };
     
On peut enregistrer ce fichier et ouvrir le fichier "named.conf.options" :

    nano /etc/bind/named.conf.options
    
Il faut ensuite rajouter la ligne suivante :

    allow-transfer { 192.168.10.6; };
    
On peut maintenant enregistrer le fichier.
Il faut maintenant créer le fichier "db.carnofluxe.local" 
    
    nano /etc/bind/db.carnofluxe.local
    
Et il faut y renseigner la configuration suivante : 

    ;
    ; BIND data file for carnofluxe.local
    ;
    $TTL    604800
    @       IN      SOA     dns1.carnofluxe.local. root.carnofluxe.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

    @       IN      NS      dns1.carnofluxe.local.
    @       IN      A       192.168.10.10
    dns1    IN      A       192.168.10.5
    www     IN      A       192.168.10.10
    supervision     IN      A       192.168.10.10

Maintenant que le fichier et complet, il faut l'enregistrer et créer le fichier de zone inverse : 

    nano /etc/bind/db.10.10.168.192
    
Et comme pour notre fichier de zone directe, il faut y renseigner la configuration suivante : 

    ;
    ; BIND reverse data file for 192.168.10.10 net
    ;
    $TTL    604800
    @       IN      SOA     10.10.168.192.in-addr.arpa. root.10.10.168.192.in-addr.arpa. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
    @       IN      NS      carnofluxe.local.
    ;
    10.10.168.192.in-addr.arpa.     IN      PTR     carnofluxe.local.
    5       IN      PTR     dns1.carnofluxe.local.
    10      IN      PTR     www.carnofluxe.local.


Maintenant que l'on a effectué la configuration de zone inverse, on peut enregistrer le fichier.

Il faut maintenant redémarrer le service bind9, avec la commande suivante : 

    service bind9 restart

Une fois le service redémaré, on peut avoir son status avec la commande suivante : 

    service bind9 status

Nous avons donc fini de configurer le serveur DNS / DHCP.  
             
  
## Serveur DNS esclave

### Pré-requis

Avant de configurer le DNS esclave, il y a plusieurs étapes à effectuer. Pour commencer il faut définir un nom à notre machine : 
                    
    sudo su
    
On passe en root et ensuite on ouvre le fichier « hosts » :
	              
    nano /etc/hosts

Et on modifie la ligne 2 (127.0.1.1) il faut remplacer par son nom machine avec son nom de domaine "dns1.carnofluxe. local".
	    
    127.0.1.1         dns2.carnofluxe.local
    
On ouvre ensuite le fichier « hostname » :

    nano /etc/hostname
 
Et on modifie le nom par anthony-virtual-machine par « dns2 ».
 
    dns2
      
Et on redémarre la machine pour que les modifications soit prises en compte

    reboot
    
Une fois que la machine à redémarrer, il faut télécharger tout les paquets : 

    apt-get update && apt-get upgrade
    apt-get install bind9
    apt-get install openssh-server
    
 Une fois tout les packets installés correctement, il faut configurer une IP fixe à notre serveur.
 Pour cela on ouvre le fichier interfaces :

    nano /etc/network/interfaces
    
 Ensuite, on modifie la configuration en ajoutant les lignes suivantes : 

    auto ens33
    iface ens33 inet static
    address 192.168.10.6
    netmask 255.255.255.0
    gateway 192.168.10.2
    
 Pour finir, on redémarre pour que tout soit pris en compte.
 
     reboot
     
Nous avons maintenant fini avec les pré-requis pour ce serveur.

### DNS Esclave

Tout comme le DNS maître, il faut modifier le fichier "named.conf.local" : 
    
    nano /etc/bind/named.conf.local
    
Il faut y ajouter la configuration suivante : 

    zone "carnofluxe.local" IN  {
        type slave;
        masters { 192.168.10.5; };
        file "/var/lib/bind/db.carnofluxe.local";
    };

    zone "10.10.168.192.in-addr.arpa" IN {
        type slave;
        masters { 192.168.10.5; };
        file "/var/lib/bind/db.10.10.168.192";
    };
 
Une fois cela effectué,on peut enregistrer le fichier.
Il faut maintenant redémarrer bind9 : 

    service bind9 restart
    
Et on peut regarder son statut avec la commande suivante : 

    service bind9 status
    
Un fois que tout cela a été effectué, on peut regarder dans le dossier bind, si les fichiers ".db" ont bien été créer :

    ls /var/lib/bind
    
Nous avons donc fini de configurer le serveur DNS Esclave.

## Serveur HTTP

### Pré-requis

Avant de configurer les virtuals hosts, il y a plusieurs étapes à effectuer. Pour commencer il faut définir un nom à notre machine : 
                    
    sudo su
    
On passe en root et ensuite on ouvre le fichier « hosts » :
	              
    nano /etc/hosts

Et on modifie la ligne 2 (127.0.1.1) il faut remplacer par son nom machine avec son nom de domaine "serv_http.carnofluxe. local".
	    
    127.0.1.1         serv_http.carnofluxe.local
    
On ouvre ensuite le fichier « hostname » :

    nano /etc/hostname
 
Et on modifie le nom par anthony-virtual-machine par « serv_http ».
 
    serv_http
      
Et on redémarre la machine pour que les modifications soit prises en compte

    reboot
    
Une fois que la machine à redémarrer, il faut télécharger tout les paquets : 

    apt-get update && apt-get upgrade
    apt-get install apache2
    apt-get install openssh-server
    
 Une fois tout les packets installés correctement, il faut configurer une IP fixe à notre serveur.
 Pour cela on ouvre le fichier interfaces :

    nano /etc/network/interfaces
    
 Ensuite, on modifie la configuration en ajoutant les lignes suivantes : 

    auto ens33
    iface ens33 inet static
    address 192.168.10.10
    netmask 255.255.255.0
    gateway 192.168.10.2
    
 Pour finir, on redémarre pour que tout soit pris en compte.
 
     reboot
     
Nous avons maintenant fini avec les pré-requis pour ce serveur.

### Virtuals Hosts

Il faut tout d'abord créer les deux répertoires qui contiendront les VHosts : 
    
    mkdir /var/www/html/carnofluxe/public_html
    mkdir /var/www/html/supervision/public_html
    
Maintenant que l'on a crée les répertoires, il faut changer leurs droits avec les commandes suivantes : 
    
    chown -R $USER:$USER /var/www/html/carnofluxe/public_html
    chown -R $USER:$USER /var/www/html/supervision/public_html
    chmod -R 755 /var/www/html/
    
Maintenant que nous avons gérer les différentes permissions, il faut créer un page test pour chaque VHosts :

    nano /var/www/html/carnofluxe/public_html/index.html

On écrit les lignes si-dessous dans le fichier :
    
    <html>
      <head>
        <title>www.carnofluxe.local</title>
      </head>
      <body>
        <h1>Bonjour, bienvenue sur le site "www.carnofluxe.local"</h1>
      </body>
    </html>

Ensuite, on peut enregistrer et fermer le fichier. Il faut faire de même avec le second VHost :

    nano /var/www/html/supervision/public_html/index.html
    
On écrit comme précédemment les lignes suivantes dans le fichier : 

    <html>
      <head>
        <title>supervision.carnofluxe.local</title>
      </head>
      <body>
        <h1>Bonjour, bienvenue sur le site "supervision.carnofluxe.local"</h1>
      </body>
    </html>
    
On peut maintenant enregistrer et fermer le fichier.

Il nous faut maintenant créer les fichiers de configuration de nos VHosts : 

    nano /etc/apache2/sites-available/carnofluxe.local.conf
    nano /etc/apache2/sites-available/supervision.carnfluxe.local.conf
    
On va modifier le fichier de configuration "carnofluxe.local.conf" en y ajoutant les lignes suivantes :
    
    ServerAdmin webmaster@carnofluxe.local
    ServerName carnofluxe.local
    ServerAlias www.carnofluxe.local
    DocumentRoot /var/www/html/carnofluxe/public_html
    
 Une fois que l'on a fini, on peut enregistrer puis fermer le fichier et refaire une manipulation semblable avec notre deuxième VHost en y ajoutant les lignes suivantes : 
  
    ServerAdmin webmaster@supervision.carnofluxe.local
    ServerName supervision.carnofluxe.local
    DocumentRoot /var/www/html/supervision/public_html
    
On peut ensuite enregistrer puis fermer le fichier. 

Pour mettre les VHosts en ligne, il faut les activer ainsi :
    
    a2dissite 000-default.conf

Une fois la configuration de base désactivée, on peut activer nos VHosts : 
    
    a2ensite carnofluxe.local.conf
    a2ensite supervision.carnofluxe.local.conf
    
Ensuite pour que apache prenne en compte les nouveaux VHosts, il faut le redémarrer : 

    systemctl restart apache2
    
Pour finir la configuration de nos VHosts il faut ouvrir le fichier "hosts": 

    nano /etc/hosts
    
 Et y écrire les lignes suivantes : 
 
    192.168.10.10   carnofluxe.local
    192.168.10.10   supervision.carnofluxe.local

Une fois que cela est effectué, on peut enregistrer le fichier et nos VHosts sont configurés.
    

    
