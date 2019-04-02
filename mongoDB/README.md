# MongoDB

## Description du sujet

### Modéliser dans MongoDb des équipes (de football par ex.) :
* nom
* couleurs
* stade
* effectifs (liste de joueurs)

### Modéliser dans MongoDb des joueurs (de football par ex.) :
* nom
* prénom
* date de naissance
* taille
* poids
* poste

### Modéliser dans MongoDb des matchs (de football par ex.) :
* équipe « domicile »
* équipe « équipe extérieur »
* compétition
* score équipe « domicile »
* score équipe « extérieur »
* joueurs équipe « domicile », avec pour chaque joueur sa note
* joueurs équipe « extérieur », avec pour chaque joueur sa note

### Mettre en place le nécessaire pour l’optimisation de requêtes
* D’équipe par nom
* De joueur par nom

### Exprimer la requête de sélection des joueurs pour un poste donné et un âge max (ex : arrière droit de moins de 25 ans)

### Exprimer les requêtes d’insertion 
* d’équipes, 
* de joueurs, 
* de matchs

### Construire une nouvelle collection stockant les joueurs ayant joué au moins X (par ex : 3) matchs, avec pour chaque joueur la moyenne de ses notes

## Les Commandes afin de constuire le base de donné

### Lancement de la base de données
```CQL
service mongodb start
# On ajoute l'option smallfiles pour une base de données de moins de 3GB
mongod --smallfiles
mongo
# Crée une base de données mydb et s'y connecte
use mydb
# Crée une collection "player"
db.createCollection("players")
# Crée une collection "teams"
db.createCollection("teams")
# Crée une collection "matches"
db.createCollection("matches")
# On ajoute un index sur les noms dans la collection des équipes
db.teams.ensureIndex({"name":1})
# On ajoute un index sur les noms dans la collection des joueurs
db.players.ensureIndex({"name":1})
```

### Exprimer les requêtes d’insertion 
```CQL
# Trouve Claude Francois Jr après insertion des joueurs
# On met les champs de la recherche entre {} séparés par une virgule, et $gt pour dire qu'on cherche une date de naissance supérieure à 02 01 1993
# On rajoute pretty() pour un résultat plus lisible
db.players.find(
     {
      position: "right back",
      birthdate: {$gt: "1993-01-02"}
     }
).pretty()

#On ajoute 3 joueurs
#On rentre la date de naissance au format ISO pour les recherches
#La taille en cm et le poids en kg
db.players.insert([
     {
      firstname: "Luc",
      lastname: "Pichon",
      birthdate: "1982-09-02",
      size: "170",
      weight: "70",      
      position: "right back"
     },
     {
      firstname: "Claude Jr",
      lastname: "Francois",
      birthdate: "1995-03-22",
      size: "165",
      weight: "45",      
      position: "right back"
     },
     {
      firstname: "Jean",
      lastname: "d'Arc",
      birthdate: "1998-11-07",
      size: "210",
      weight: "110",      
      position: "goalkeeper"
     }
])

# On ajoute 3 équipes
# Plutôt que d'ajouter des noms de joueurs, on ajoute l'id vers le joueur. De cette manière, si le joueur change de nom, se remarie ou autre il n'y a pas de problème de lien.
db.teams.insert(
[
     {
      name: "Liverpool",
      colors: ["red","yellow"],
      players: [db.players.findOne({firstname:"Luc", lastname:"Pichon"},{_id:1})]   
     },
          {
      name: "Tse-team",
      colors: ["green","white"],
     },
          {
      name: "France",
      colors: ["blue","white","red"],
      players: [
                db.players.findOne({firstname:"Jean"},{_id:1}),
                db.players.findOne({firstname:"Claude Jr", lastname:"Francois"},{_id:1})                
               ]   
     }
])

db.matches.insert(
     {
      hometeam:db.teams.findOne({name:"Liverpool"},{_id:1}),
      extteam: db.teams.findOne({name:"France"},{_id:1}),
      competition:"pour le fun",
      homescore:"0",
      extscore:"3",
      homeplayersscore:
        [
           {
             player:db.players.findOne({firstname:"Jean"},{_id:1})._id,
             score:"0"
           },
           {
              player:db.players.findOne({firstname:"Luc"},{_id:1})._id,
              score:"0"
           }
        ],
      extplayersscore:
         [
            {
               player:db.players.findOne({firstname:"Claude Jr"},{_id:1})._id,
               score:"3"
             }
         ]
     }
)
```

### Autres commandes:
```CQL
# Enlever tous les joueurs nés le 02 09 1982
db.players.remove({birthdate: "1982-09-02"})
# Afficher les équipes avec les toutes les infos joueurs
db.teams.aggregate([
  //on unwind les players
  {
     $unwind:"$players"
  },
  //on fait un lookup de la collection players sur le champs players._id en relation avec le champ id de la collection players
  {
     $lookup:
       {
          from:"players",
          localField:"players._id",
          foreignField:"_id",
          as:"playerlist"
       }
  },
  //on unwind la playerlist 
{ "$unwind": "$playerlist" },
    // on regroupe ce qu'on affiche
    { "$group": {
        "_id":"$_id",
        "name": {"$first":"$name"},
        //on push car c'est un array
        "colors":{$push:"$colors"},
        "playerlist": { "$push": "$playerlist" }
    }}
]).pretty()
```
