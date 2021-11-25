library(sf)
library(tidyverse)


# read in seals data
seals_sf <-st_read("G:/My Drive/academia/stonybrook/GSS554/final project/data/seals/Seals_WV03_20160225140324_10400100196BE200_2021Nov22_02.shp")
st_transform(seals_sf, 3031)

# read in floe data and change column names
floes_sf <- st_read("G:/My Drive/academia/stonybrook/GSS554/final project/data/SeaIce/image_floes/floes.shp")
st_transform(floes_sf, 3031)
colnames(floes_sf) <- c("FPolyArea","FPolyScene", "geometry")

# check for identical crs
st_crs(seals_sf)== st_crs(floes_sf)


##------------------#
# Modify the data
#-------------------#
# add index to floes
floes_sf <- tibble::rowid_to_column(floes_sf, "FloeID")


#------------------#
# Join the seals to floes
#-------------------------#

# intersect floes and seals
intersection <- st_intersection(x = floes_sf, y = seals_sf)


#count the overlaps
intersection_count <- intersection %>% 
  group_by(FloeID) %>% 
  count()

intersection_count <- intersection_count %>%
  select(FloeID, n)




seals_joined <- st_join(intersection, intersection_count, by = "FloeID")

seals_filtered <- seals_joined %>% 
  distinct(UID, .keep_all = TRUE)

discrete_floes_filtered <- seals_joined %>% 
  distinct(FloeID.x, .keep_all = TRUE)


# seals_filtered <- seals_joined %>% 
#   distinct(FloeID.x, .keep_all = TRUE)

st_write()
  
df <- subset (discrete_floes_filtered, select = -c(FPolyArea, FPolyScene))


seals_joined <- c("Floe_UID", "Floe_Area", "Imagery_SceneID", "Seal_UID", "Seal_Area", )


