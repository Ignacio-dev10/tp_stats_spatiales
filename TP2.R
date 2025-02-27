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

## 1. Importation du fond

carte <- st_read("fonds/commune_francemetro_2021.gpkg")


## 2. Résumé descriptif
str(carte)
summary(carte)

## 3. Regarder 10 premiers lignes et colonne

View(carte[1:10,17])


## 4. Affichage du système de projection

st_crs(carte)

## 5. Table uniquement avec communes bretonnes

carte_bretagne <- carte %>%
  filter(reg == 53) %>%
  select(code, libelle, epc, dep, surf)

## 6. Vérification classe

class(carte_bretagne)


## 7. Plot

plot(carte_bretagne)

## 8. Avec st_geometry

plot(st_geometry(carte_bretagne), lwd=0.5)

## 9. Surface

carte_bretagne <- carte_bretagne %>%
  mutate(surf2 = st_area(geom))

## 10. Changement en km2

str(carte_bretagne$surf2)

# Technique pas fou : carte_bretagne$surf2 <- carte_bretagne$surf2/1000000

carte_bretagne <- carte_bretagne %>%
  mutate(surf2=units::set_units(surf2, km^2))


## 11. Surf et surf2 égales ?

# Non, jsp


## 12. Surface des départements 

dep_bretagne <- carte_bretagne %>%
  group_by(dep) %>%
  summarise(surface = sum(surf2))
plot(dep_bretagne)
