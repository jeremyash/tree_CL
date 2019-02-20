library(rmarkdown)
library(tidyverse)

#----------------------------------------------------------------------------

#############################################################################
## APPLY MD RENDER ACROSS ALL SPECIES
#############################################################################

# pull spp codes
sp_dat <- read_csv("data/spp_codes.csv") %>% 
  rename(spp_code = "spp code") %>% 
  mutate(spp_code = paste("s", spp_code, sep = "")) %>% 
  pull(spp_code)



# apply species template
lapply(sp_dat, function(x) {
  render("figures_md/species_template.Rmd", 
         output_dir = "figures_md/sp_plots",
         output_file = paste(x, ".pdf", sep = ""), 
         params = list(SPP = x))
})


