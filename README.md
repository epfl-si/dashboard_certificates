# dashboard_certificates

Création d'un dashboard pour visualiser ses propres certificats ayant une échéance à court terme.

## Pré-requis

- Docker
- R
- DBeaver

## Marche à suivre

1) Cloner le repo.
2) Créer le dossier *internal_data* sous *./prod_to_dev* (dossier déjà présent dans repo).
3) Placer les fichiers JSON contenant les données de production à importer dans le dossier *prod_to_dev/internal_data* (cmdb.json et ssl.json).
4) FIXME : Toujours nécessaire ou non ? -> Formater le fichier ssl.json avec `make reformat_ssl_json`.
5) Renommer le fichier *.env.exemple* en *.env* et remplacer *<...>* par un mot de passe pour elasticsearch.
6) FIXME : Problème de charge (mémoire, CPU, ...) sur certains ordis et utiliser `make elasticsearch_healthy` pour s'assurer que l'état du cluster n'est pas *red* sinon KO. -> Démarrer les containers (elasticsearch, kibana et shiny + sqlite) avec `make init`.
7) Alimenter les bases de données (elasticsearch et sqlite) avec `make data`.
8) TODO

## TODO / FIXME

- add_cmdb_data.R (voir FIXMEs) -> correspondance entre données de ssl et cmdb KO + ajout colonnes rifs_flag et adminit_flag dans Serveur_Personne KO
- fixer impossibilité de lancer scripts R via commande dans Makefile
- utiliser .env pour ne pas devoir modifier manuellement configurations si scripts lancés dans container ou en local
- dashboard -> finir tableau (pour l'instant ébauche de tableau avec toutes les données), créer page de détails et créer vues différentes en fonction du sciper / fonction du user
- créer un script à part pour packages de R
- Makefile -> ne doit pas poser problème si même commande relancée plusieurs fois de suite (KO avec génération du token pour `make secure`)