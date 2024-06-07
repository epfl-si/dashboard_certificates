# dashboard_certificates
Création d'un dashboard pour visualiser ses propres certificats ayant une échéance à court terme.

---------------------------------------------

Utiliser ce lien pour docker : https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html.

Utiliser ces repos pour elasticsearch et kibana : https://github.com/LisaHJung.

## Commandes utiles

- docker run --name es01 --net elastic -p 9200:9200 -it -m 1GB docker.elastic.co/elasticsearch/elasticsearch:8.13.2
- docker run --name kib01 --net elastic -p 5601:5601 docker.elastic.co/kibana/kibana:8.13.2
- docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana * -> pour regénérer le tocken*
- docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic * -> pour regénérer le mot de passe (utiliser user = elastic)*

## Concepts

- Elasticsearch = base de données → serveur mysql
- Kibana = interface graphique → phpmyadmin