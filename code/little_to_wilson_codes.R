library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
library(sp)
library(rgeos)
library(raster)
library(rgdal)
library(scales)
library(units)
library(viridis)
library(stringr)

#----------------------------------------------------------------------------

########################################
## LOAD DATA
########################################

little_files <- list.files("gis/little_sh")

horn_sp <- read.csv("data/spp_codes.csv", stringsAsFactors = FALSE) %>% 
  mutate(genu = str_sub(str_to_lower(GENUS), start = 1, end = 4),
         spec = str_sub(SPECIES, start = 1, end = 4)) %>% 
  unite(little_code, c("genu", "spec"), sep = "") %>% 
  mutate(spp.code = paste("s", as.character(spp.code), sep = ""))

horn_codes <- horn_sp %>% 
  pull(little_code)




# not in little files
setdiff(horn_codes, little_files)

# Nyssa biflora
# Taxodium ascendens not in Little
caryalba <- carytome
calodecu <- libodecu



# write and read back in to remove problematic species
# write_csv(horn_sp, "data/little_horn_sp.csv")
horn_codes_sub <- read_csv("data/little_horn_sp.csv")
horn_codes_little <- horn_codes_sub %>% 
  pull(little_code)


horn_codes_sub$little_code[horn_codes_sub$little_code == "ac"]

#----------------------------------------------------------------------------


lapply(horn_codes_little, function(x) {
  sh_path <- paste("gis/little_sh/", x, sep ="")
  sh_name <- horn_codes_sub$spp.code[horn_codes_sub$little_code == x]
  
  sh_out_path <- paste("gis/little_horn_sp/", sh_name, sep = "")
  sh <- readOGR(sh_path)
  writeOGR(sh, dsn = sh_out_path, layer = sh_name, driver = "ESRI Shapefile")
  
})


lapply(horn_codes_little, function(x) {
  sh_path <- paste("gis/little_sh/", x, sep ="")
  sh_name <- horn_codes_sub$spp.code[horn_codes_sub$little_code == x]
  
  sh_out_path <- "gis/little_horn_sh"
  sh <- readOGR(sh_path)
  proj4string(sh) <- CRS("+init=epsg:4267")
  writeOGR(sh, dsn = sh_out_path, layer = sh_name, driver = "ESRI Shapefile")
  
})














