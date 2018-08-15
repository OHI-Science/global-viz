library(knitr)
library(ggplot2)
library(stringr)

dir.create(path = "output/")
opts_knit$set(base.dir = "output/")

for(i in 1:5) {
  filename <- str_to_lower(str_replace_all(rownames(mtcars), " ", ""))[i]
  knit2pdf(input  = "region_card.Rnw", output = paste0("output/", filename, ".tex"), compiler = "xelatex")
}
