#### TP2 Stats_spatiales ####

## Importation des packages

require(dplyr)

require(sf)

#### Exercice 1 ####

## 0. Importation des fonds

url <- "https://minio.lab.sspcloud.fr/julienjamme/geographies/commune_francemetro_2021.gpkg"
file_name <- "commune_francemetro_2021.gpkg"
file_path <- "./fonds/"

if(!dir.exists("fonds")) dir.create("fonds/", recursive = TRUE)

download.file(url = url, destfile = paste0(file_path, file_name))


## 1.