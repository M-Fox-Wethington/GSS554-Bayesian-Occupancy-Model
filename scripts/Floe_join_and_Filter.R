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

occupied <- seals_joined %>% 
  distinct(FloeID.x, .keep_all = TRUE)

occupied <- occupied %>% 
  distinct(UID, .keep_all = TRUE)

st_write(occupied, "occupied_floes_2021Nov24.shp" )

#REOPEN AND CORRECT FOR THE MISMATCHED COLUMNS/COLNAMES

occupied <- st_read("G:/My Drive/academia/stonybrook/GSS554/final project/GSS554-Bayesian-Occupancy-Model/model_inputs/occupied_floes_2021Nov24.shp")
absences <- st_read("G:/My Drive/academia/stonybrook/GSS554/final project/GSS554-Bayesian-Occupancy-Model/model_inputs/AbsentFloes_Sample5000.shp")

#Take only count and floe area
absences <- absences[,c(1,3)]

#rename columns to match the "occupied" floes
absences <- absences %>% 
  rename(floe_ar = area,
         Count = Join_Count)

#Remame occupied floes to match absences df
occupied <- occupied %>% 
  rename(Count = n)

#Reorder the columns so we can stack the dataframes
occupied <- occupied %>% 
  relocate(Count, .before = FloeID_x) %>% 
  relocate(floe_ar, .before = FloeID_x)


st_write(occupied, "occupied_floes_adjusted_2021Nov24.shp" )
st_write(absences, "absences_floes_adjusted_2021Nov24.shp" )


