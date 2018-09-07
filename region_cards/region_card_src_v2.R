## load required packages, install if needed
library(knitr)
library(ggplot2)
library(stringr)
library(tidyverse)
library(ggrepel) # install.packages("ggrepel")
library(cowplot) # install.packages("cowplot")

## setwd and define paths for outputs etc
setwd("./region_cards")
if(!file.exists("output")){dir.create(path = "output/")}
knitr::opts_knit$set(base.dir = "output/", echo = FALSE, warning = FALSE)

## generate general header information
makedate <- format(Sys.time(), "%b %d %Y")

## read in time series dataset with information for all regions' ids and names
score_data_loc <- "https://raw.githubusercontent.com/OHI-Science/ohi-global/draft/eez/scores.csv"
rgn_data_loc <- "https://raw.githubusercontent.com/OHI-Science/ohi-global/draft/eez/spatial/regions_list.csv"

scores <- read.csv(score_data_loc) %>%
  rename(abb = "goal", rgn_id = "region_id")
region_names <- read.csv(rgn_data_loc, colClasses = c(rgn_name = "character")) %>% 
  select(rgn_id, rgn_name) 
  

## goals dataframe
goals <- c("Index", 
           "Artisanal Opporunities", 
           "Biodiversity",
           "Carbon Storage",
           "Clean Waters", 
           "Livelihoods and Economies",
           "Coastal Protection", 
           "Food Provision",
           "Natural Products", 
           "Sense of Place", 
           "Tourism and Recreation")

goals_abbrev <- c("Index", "AO", "BD", "CS", "CW", "LE", "CP", "FP", "NP", "SP", "TR")

goals_descrip <- c("Overall Ocean Health Index score", 
                   "Opportunity for small-scale fishers to supply <br> catch to their families, community or local market", 
                   "Conservation status of native marine species and key habitats", 
                   "Condition of coastal habitats that store and <br> sequester atmospheric carbon", 
                   "Degree to which oceans are free of contaminants such as  <br> chemicals, excessive nutrients, human pathogens, and trash", 
                   "Coastal and ocean-dependent livelihoods (job quantity and quality) <br> and economies (revenues) produced by marine sectors", 
                   "Amount of protection provided by marine and coastal habitats <br> serving as natural buffers against incoming waves", 
                   "Sustainable harvest of seafood from wild-caught <br> fisheries and mariculture ", 
                   "Natural resources that are sustainably extracted <br> from living marine resources", 
                   "Conservation status of iconic species and geographic <br> locations that contribute to cultural identity", 
                   "Value people have for experiencing and enjoying <br> coastal areas and attractions")

goals <-  data.frame(goal = goals, abb = goals_abbrev, description = goals_descrip)

scores_description <- scores %>% 
  left_join(goals, by = "abb") %>% 
  mutate(label = ifelse(year == max(year), as.character(abb), NA_character_))


## create the cards!
for(rgn in region_names$rgn_id){ # for(rgn in c(16, 224, 70))
  
  ## subset score data for country/region
  rgn_score_data <- scores_description %>% 
    dplyr::filter(rgn_id == rgn) %>% 
    dplyr::filter(dimension == "score") %>% 
    dplyr::filter(abb %in% c("AO", "BD", "CP", "CS", "CW", "FP", "Index", "LE", "NP", "SP", "TR"))
  
  ## by-region header and scorecard filename information
  regioncard_title <- region_names$rgn_name[region_names$rgn_id == rgn]
  filename <- str_to_lower(str_replace_all(regioncard_title, " ", "_"))
  
  
  ## create time series plot
  time_series_rgn_plot <- ggplot(rgn_score_data %>% filter(abb != "Index"),
                                 aes(x = year, y = score, color = goal)) +
    geom_line(data = rgn_score_data %>% filter( abb == "Index"),
              aes(x = year, y = score), size = 1.8, color = "gray20", alpha = 1) +
    geom_point(data = rgn_score_data %>% filter(abb == "Index"),
               aes(x = year, y = score, text = paste("Goal: ", goal, "<br>Year:", year, "<br>Score:", score, "<br>Description: ", description)), size = 2, color = "gray20") +
    geom_text_repel(data = rgn_score_data%>% filter( abb == "Index"),
                    aes(label = label), 
                    na.rm = TRUE,
                    fontface = "bold",
                    # hjust = 0,
                    nudge_x = 0.01,
                    nudge_y = 0.1,
                    # direction = "y",
                    point.padding = unit(8, "points"),
                    size = 3, 
                    segment.color = NA, 
                    color = "gray20") +
    geom_line(aes(group = goal), alpha = 1, size = 1) +
    geom_point(aes(text = paste("Goal: ", goal, "<br>Year:", year, "<br>Score:", score, "<br>Description: ", description)), size = 1.2) +
    scale_x_continuous(breaks = seq(2012, 2018, 1)) +
    labs(y = "Score", color = "Goal")+ 
    theme_cowplot() +
    theme(# axis.text.x = element_text(angle = 30),
      axis.title.x = element_blank(),
      legend.position = "None") +
    geom_text_repel(aes(label = label),
                    na.rm = TRUE,
                    fontface = "bold",
                    nudge_x = 0.1,
                    nudge_y = 0,
                    point.padding = unit(8, "points"), 
                    size = 3, 
                    segment.color = NA) +
    scale_color_brewer(palette = "Spectral") +
    guides(colour = guide_legend(override.aes = list(size = 3)))
  
  
  ## select region inset map png from list of files in region maps folder
  inset_maps <- list.files("../region_maps/figures/inset_maps", full.names = TRUE)
  region_inset_map <- inset_maps[gsub(".png", "", basename(inset_maps)) == filename]
  
  ## knit the card together
  knit2pdf(input  = "region_card_v2.Rnw", output = paste0("output/", filename, ".tex"), compiler = "xelatex")
  
  
}