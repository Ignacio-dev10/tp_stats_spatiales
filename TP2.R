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

## 13. Fond départementale
dep_bretagne2 <- carte_bretagne %>%
  group_by(dep) %>%
  summarise(geometry = st_union(geom))

plot(dep_bretagne2)


## 14. Création des centroïdes

centroid_dept_bretagne <- st_centroid(dep_bretagne2)
str(centroid_dept_bretagne)
class(centroid_dept_bretagne$geometry)
print(centroid_dept_bretagne)

#a. C'est une géométrie de style POINT

#b. Représentation des centroïdes

plot(st_geometry(dep_bretagne2))
plot(st_geometry(centroid_dept_bretagne$geometry), add=TRUE)


ggplot() +
  geom_sf(data = dep_bretagne2) +
  geom_sf(data = centroid_dept_bretagne, color = "dark green", size = .5) +
  theme_void() +
  theme(panel.grid = element_blank(), panel.border = element_blank()) +
  labs(title = "les départements et leur centroïdes")


#c. Rajouter le libellé des départements

dep_lib <- as.data.frame(list(c("22","29","35","56"),c("Côtes-d'Armor","Finistère","Ille-et-Vilaine","Morbian")),
                      col.names = c("dep", "libelle_dep"))

centroid_dept_bretagne <- centroid_dept_bretagne %>%
  full_join(dep_lib, by = "dep")


#d. Récupération des coordonnées

centroid_coords <- as.data.frame(st_coordinates(centroid_dept_bretagne))
st_drop_geometry(centroid_coords)

centroid_coords <- cbind(cbind(centroid_coords, centroid_dept_bretagne$dep), centroid_dept_bretagne$libelle_dep)

# e. Affichage sur la carte

plot(st_geometry(dep_bretagne2))
plot(st_geometry(centroid_dept_bretagne$geometry), pch = 16, col = "orangered", add=TRUE)
text(
  x = centroid_coords$X,
  y = centroid_coords$Y,
  labels = centroid_coords$`centroid_dept_bretagne$libelle_dep`,
  pos = 3,
  cex = 0.8,
  col = "orangered"
)


## 15. Retrouver dans quel commune se trouve chaque centroïde

?st_intersects
commune_centroid_bret <- st_intersects(carte_bretagne, centroid_dept_bretagne)

commune_centroid_bret <- carte_bretagne[which(lengths(commune_centroid_bret)>0),]
