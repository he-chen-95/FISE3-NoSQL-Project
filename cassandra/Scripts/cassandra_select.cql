# Sélection des données de la station '6901'
SELECT * FROM meteoDS WHERE stationID = 6901 AND longitude = 4.83 AND latitude = 45.73;

# Sélection des données de la station '6902' durant 13h à 14h de 09/12/2018
SELECT * FROM meteoDS WHERE stationID = 6902 AND longitude = 4.56 AND latitude = 45.43 AND horodate >= '2018-12-09 13:00+0100' AND horodate <= '2018-12-09 14:00+0100';
