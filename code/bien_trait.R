library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
# library(sp)
# library(rgeos)
# library(raster)
# library(rgdal)
# library(scales)
# library(units)
# library(viridis)
library(BIEN)


########################################
## load data
########################################

horn <- read_csv("raw_data/horn_spp.csv") %>% 
  unite(sp_name, GENUS, SPECIES_HORN, sep = " ") %>%
  # select(SPECIES_BIEN, sp_name) %>% 
  mutate(sp_name = coalesce(SPECIES_BIEN, sp_name)) 
  

#----------------------------------------------------------------------------

########################################
## download trait data
########################################
# 
horn_trait <- lapply(horn, function(x) BIEN_trait_species(x))[[1]]

saveRDS(horn_trait,"raw_data/horn_trait.RDS")



# subset to North America


horn_trait <- readRDS("raw_data/horn_trait.RDS") %>% 
  mutate(longitude = as.numeric(longitude),
         latitude = as.numeric(latitude)) 
# 
# 
# horn_get_ctds <- horn_trait %>% 
#   filter(is.na(longitude)) %>% 
#   select(scrubbed_species_binomial, trait_name, url_source) %>% 
#   distinct() 
# 
# write_csv(horn_get_ctds, "raw_data/horn_get_ctds.csv")

#check species 

bien_spp <- unique(horn_trait$scrubbed_species_binomial)

sp_coverage <- sort(horn[horn %in% bien_spp])
sp_missing <- setdiff(horn$sp_name, sp_coverage )




# traits available
sp_traits <- horn_trait %>% 
  group_by(scrubbed_species_binomial, trait_name) %>% 
  summarise(n_trait_values = n()) %>% 
  ungroup() %>% 
  spread(trait_name, n_trait_values)

write_csv(sp_traits, "data/horn_trait_n_observations.csv")



# trait means and coverage

unique(horn_trait$trait_name)

cat_traits <- c("whole plant vegetative phenology",
                "whole plant woodiness", 
                "whole plant growth form diversity", 
                "whole plant growth form",
                "whole plant sexual system",                          
                "whole plant dispersal syndrome",                     
                "flower pollination syndrome" )


cat_traits_df <- horn_trait %>% 
  select(scrubbed_species_binomial, trait_name, trait_value) %>%
  filter(trait_name %in% cat_traits) %>% 
  distinct() %>% 
  filter(trait_name != "whole plant growth form diversity") %>% 
  slice(-208) %>% 
  spread(trait_name, trait_value)



sp_traits_df <- horn_trait %>% 
  select(scrubbed_species_binomial, trait_name, trait_value) %>%
  group_by(scrubbed_species_binomial, trait_name) %>% 
  filter(!(trait_name %in% cat_traits)) %>% 
  mutate(trait_value = as.numeric(trait_value)) %>% 
  summarise(mean_value = mean(trait_value, na.rm = TRUE)) %>% 
  ungroup() %>% 
  spread(trait_name, mean_value) %>% 
  left_join(cat_traits_df, by = "scrubbed_species_binomial")
  
write_csv(sp_traits_df, "data/horn_trait_dat.csv")
  
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

########################################
## testing
########################################

usa <- map_data("usa")

horn_spatial <- horn_trait %>% 
  select(scrubbed_species_binomial, longitude, latitude) %>% 
  distinct() 


ggplot(usa, aes(long, lat, group = group)) +
  geom_polygon(fill = NA, color = "black") +
  geom_point(aes(longitude, latitude, group = scrubbed_species_binomial), data = horn_spatial)







BIEN_trait_species("Quercus montana")

BIEN_trait_species("Notholithocarpus densiflorus")

nyssa <- BIEN_trait_genus("Nyssa")
























 