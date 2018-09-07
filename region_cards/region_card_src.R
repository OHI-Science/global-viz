
setwd("./region_cards")

library(knitr)
library(ggplot2)
library(stringr)
library(tidyverse)
library(ggrepel)
library(cowplot)

dir.create(path = "output/")
knitr::opts_knit$set(base.dir = "output/", echo = FALSE)

regioncard_title <- paste("COUNTRYNAME")
makedate <- format(Sys.time(), "%b %d %Y")

for(i in 1:3) {
  #filename <- str_to_lower(str_replace_all(rownames(mtcars), " ", ""))[i]
  filename <- "chile_test"
  knit2pdf(input  = "region_card.Rnw", output = paste0("output/", filename, ".tex"), compiler = "xelatex")
  #testplot <- ggplot(mtcars[i,], aes(x = cyl, y = disp) ) + geom_point()
}

##Socere ingormation for plots
scores <- read.csv('https://raw.githubusercontent.com/OHI-Science/ohi-global/draft/eez/scores.csv') %>%
  rename(abb = "goal", rgn_id = "region_id")

##Necessary information for score over time plot

#Goals Description according to "short version" 

goals <-  data.frame(goal = c("Index", 
                              "Artisanal Opporunities", 
                              "Biodiversity",
                              "Carbon Storage",
                              "Clean Waters", 
                              "Livelihoods and Economies",
                              "Coastal Protection", 
                              "Food Provision",
                              "Natural Products", 
                              "Sense of Place", 
                              "Tourism and Recreation"), 
                     abb = c("Index", 
                             "AO", 
                             "BD", 
                             "CS",
                             "CW", 
                             "LE", 
                             "CP", 
                             "FP", 
                             "NP", 
                             "SP", 
                             "TR"), 
                     description = c("Overall Ocean Health Index score", 
                                     "Opportunity for small-scale fishers to supply <br> catch to their families, community or local market", 
                                     "Conservation status of native marine species and key habitats", 
                                     "Condition of coastal habitats that store and <br> sequester atmospheric carbon", 
                                     "Degree to which oceans are free of contaminants such as  <br> chemicals, excessive nutrients, human pathogens, and trash", 
                                     "Coastal and ocean-dependent livelihoods (job quantity and quality) <br> and economies (revenues) produced by marine sectors", 
                                     "Amount of protection provided by marine and coastal habitats <br> serving as natural buffers against incoming waves", 
                                     "Sustainable harvest of seafood from wild-caught <br> fisheries and mariculture ", 
                                     "Natural resources that are sustainably extracted <br> from living marine resources", 
                                     "Conservation status of iconic species and geographic <br> locations that contribute to cultural identity", 
                                     "Value people have for experiencing and enjoying <br> coastal areas and attractions")) 


scores_description <- scores %>% 
  left_join(goals, by= "abb") %>% 
  mutate(label = ifelse(year == max(year), as.character(abb), NA_character_))

chile <- scores_description %>% 
  dplyr::filter(rgn_id=='224') %>% 
  dplyr::filter(dimension == 'score') %>% 
  dplyr::filter(abb %in% c('AO', 'BD', 'CP', 'CS', 'CW', 'FP', 'Index', 'LE', 'NP', 'SP', 'TR'))


chile_plot <- ggplot(chile %>%
                       filter(abb != "Index"),
                     aes(x = year, y = score, color = goal)) +
  geom_line(data = chile %>% 
              filter( abb == "Index"),
            aes(x = year, y = score), size = 1.8, color = 'gray20', alpha = 1) +
  geom_point(data = chile %>% 
               filter( abb == "Index"),
             aes(x = year, y = score, text = paste("Goal: ", goal, "<br>Year:", year, "<br>Score:", score, "<br>Description: ", description)), size = 2, color = 'gray20')+
  geom_text_repel(data= chile %>% 
                    filter( abb == "Index"),
                  aes(label = label), 
                  na.rm=TRUE,
                  fontface = 'bold',
                  #hjust = 0,
                  nudge_x= 0.01,
                  nudge_y = 0.1,
                  #direction = "y",
                  point.padding = unit(8, "points"),
                  size= 3, 
                  segment.color=NA, 
                  color = 'gray20')+
  geom_line(aes(group = goal), alpha = 1, size = 1)+
  geom_point(aes(text = paste("Goal: ", goal, "<br>Year:", year, "<br>Score:", score, "<br>Description: ", description)), size = 1.2)+
  scale_x_continuous(breaks = seq(2012, 2018, 1))+
  labs(y="Score", color = "Goal")+ 
  theme_cowplot()+
  theme(#axis.text.x = element_text(angle = 30),
    axis.title.x = element_blank(),
    legend.position = "None") +
  geom_text_repel(aes(label = label),
                  na.rm=TRUE,
                  fontface = 'bold',
                  nudge_x= 0.1,
                  nudge_y = 0,
                  point.padding = unit(8, "points"), 
                  size= 3, 
                  segment.color=NA) +
  scale_color_brewer(palette = "Spectral")+
  guides(colour = guide_legend(override.aes = list(size = 3)))


##Information for rank plot

## Read table with region names (need regions names to disply in the plotly hover)

rgn_details <- read.csv("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/LookupTables/rgn_details.csv") %>%
  mutate(rgn_nam = as.character(rgn_nam)) %>% 
  mutate(rgn_name = ifelse(stringr::str_detect(rgn_nam,"Cura\\Sao"), "Curaçao", rgn_nam)) %>% 
  select(rgn_id, rgn_name)

##Data

rank <- scores %>% 
  dplyr::filter(dimension == "score",
                abb == "Index",
                year == 2018) %>%
  dplyr::left_join(rgn_details, by= "rgn_id") %>% 
  dplyr::arrange(desc(score)) %>% 
  dplyr::mutate(ranking = seq(1, 222, 1))

rank_plot <- ggplot()+
  geom_bar(data = rank %>% 
             filter(rgn_id != 224),
           aes(x= ranking, y= score, text= paste("Region: ", rgn_name, "<br>Ranking: ", ranking, "<br>Score: ", score)), stat = "identity", width = .2, color= '#3288BD', alpha= 0.9)+
  geom_bar(data = rank %>% 
             filter(rgn_id==224),
           aes(x= ranking, y= score, text= paste("Region: ", rgn_name, "<br>Ranking: ", ranking, "<br>Score: ", score)), stat = "identity", width = .2, color= '#9E0142', alpha= 0.9)+
  expand_limits(y = 100)+
  scale_y_continuous(name = "Score", expand = c(0,0), breaks = c(0, 25, 50, 75, 100))+
  theme_cowplot()+
  theme(panel.grid = element_blank(),
        legend.position = "none",
        axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_text(vjust = 2.6),
        axis.line.x = element_blank(),
        axis.ticks.x = element_blank()) #color = "grey45"


