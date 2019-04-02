# Créer le KeySpace météo avec des caractères pour lancer sur un seul Node.

CREATE KEYSPACE meteoDB WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
USE meteoDB;

# Créer une table (météo Dataset) pour enregistrer toutes les données de météos,
# qui incluaient des 'stationID', 'longitude', 'latitude', 'temperature', 'humidity' et 'horodate'.
# Le partition key est une combinaison des 'stationID', 'longitude', 'latitude'.
# Le clustering key est horodate.

CREATE TABLE meteoDS ( 
    stationID int, 
    longitude double, 
    latitude double, 
    horodate timestamp, 
    temperature double, 
    humidity double,
    PRIMARY KEY ( (stationID, longitude, latitude), horodate) );
