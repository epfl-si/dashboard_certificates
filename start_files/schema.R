# package install
packages <- c("RSQLite", "DBI")

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

con <- dbConnect(RSQLite::SQLite(), "./volumes/sqlite/cmdb.sqlite")

#create_table_unite <- "
#CREATE TABLE Unite (
#	id_unite INTEGER NOT NULL,
#	path TEXT NOT NULL,
#	sigle TEXT NOT NULL,
#	CONSTRAINT Unite_PK PRIMARY KEY (id_unite)
#);"

#dbExecute(con, create_table_unite)

create_table_serveur <- "
CREATE TABLE Serveur (
	ip_adr TEXT NOT NULL,
	fqdn TEXT NOT NULL,
	CONSTRAINT Serveur_PK PRIMARY KEY (ip_adr)
);"

dbExecute(con, create_table_serveur)

create_table_personne <- "
CREATE TABLE Personne (
	sciper INTEGER NOT NULL,
	cn TEXT NOT NULL,
	email TEXT NOT NULL,
	serveur_ip INTEGER,
	CONSTRAINT Personne_PK PRIMARY KEY (sciper),
	CONSTRAINT Personne_Serveur_FK FOREIGN KEY (serveur_ip) REFERENCES Serveur(ip_adr) ON DELETE SET NULL ON UPDATE CASCADE
);"

dbExecute(con, create_table_personne)