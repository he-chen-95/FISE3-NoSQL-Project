# Redis

## Description du sujet
### Simuler un call center avec Redis 
### Appels avec certaines propriétés
* Identifiant
* Heure d’appel
* Numéro d’origine
* Statut (Non affecté, Non pris en compte, En cours, Terminé) 
* Durée
* Opérateur qui le traite
* Texte descriptif
### Opérateurs avec certaines propriétés
* Identifiant
* Nom
* Prénom
* …
### Ensemble des appels en cours, à affecter
* Ajout d’un nouvel appel

### Ensemble des appels en cours de traitement, par opérateur
* Affectation d’un nouvel appel

## Les Commandes afin de constuire le base de donné

### Pour créer un nouvel appel :

```CQL
# On crée un compteur qui va servir d'identifiant aux appels et on l'initialise à 0 :

SET callId 0
INCR callId
GET callId

# 1 est ici la valeur de callId
HMSET call:1 hour "14:10"
HMSET call:1 number "0240166550"
HMSET call:1 status "non affected"
HMSET call:1 duration "25s"
# HMSET call:1 opId "5" pour ensuite ajouter un opérateur
HMSET call:1 text "he wants to talk to the product manager"
```


### Pour créer un nouvel opérateur : 
```CQL
# On crée un compteur qui va servir d'identifiant aux opérateurs:
SET opId 0
INCR opId
GET opId

#1 est ici la valeur de opId
HMSET op:1 name "Jacques"
HMSET op:1 name "Chiraq"
```

### Ensemble des appels en cours de traitement: 

```CQL
# On récupère l'id actuel des appels pour pouvoir les récupérer
client.get("callId", function(err,reply){
	var callnb=reply;
});
# Pour chaque appel, on fait un hgetall sur le hashset call:i et on regarde si le status vaut "non affected"
# S'il vaut "non affected" on le log pour l'afficher
for (i=1;i<=callnb;i++){
	hashname= "call"+i;
	client.hgetall(hashname,function(err,obj){
		if(obj.status.equals("non affected"){
			console.dir(obj);
		}
	});
```

### Ensemble des appels en cours de traitement par opérateur: 
```CQL
# On récupère l'id actuel des appels pour pouvoir tous les récupérer
client.get("callId", function(err,reply){
	var callnb=reply;
});

var callsPerOp={};
# Pour chaque appel, on fait un hgetall sur le hashset call:i et on regarde si le status vaut "treating"
for (i=1;i<=callnb;i++){
	hashname= "call"+i;
	client.hgetall(hashname,function(err,obj){
	#Si l'appel est en cours de traitement, on récupère l'id de l'opérateur qu'on transforme en integer pour pouvoir utiliser un dictionnaire
		if(obj.status.equals("treating"){
			opId=parseInt(obj.opId);
			#On ajoute au dictionnaire callsPerOp à la clé opId l'id du call actuel (i) à la liste des calls
			callsPerOp[opId.calls].push(i);
			}
		}
	});
```

### Affectation d'un nouvel opérateur :
```CQL
#Supposons qu'on veuille affecter l'opérateur dont l'id est 8 à l'appel dont l'id est 15:
HMSET call:15 status "treating"
HMSET call:15 opId 8
```
