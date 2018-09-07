library(knitr)
library(ggplot2)
library(stringr)

dir.create(path = "output/")
knitr::opts_knit$set(base.dir = "output/", echo = FALSE)

makedate <- format(Sys.time(), "%b %d %Y")

for(i in 1:2) {
  filename <- str_to_lower(str_replace_all(rownames(mtcars), " ", ""))[i]
  testplot <- ggplot(mtcars[i,], aes(x = cyl, y = disp) ) + geom_point()
  
  regioncard_title <- paste("COUNTRYNAME")
  
  
  knit2pdf(input  = "region_card_v2.Rnw", output = paste0("output/", filename, ".tex"), compiler = "xelatex")
}
