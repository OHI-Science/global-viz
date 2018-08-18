library(knitr)
library(ggplot2)
library(stringr)

dir.create(path = "output/")
knitr::opts_knit$set(base.dir = "output/", echo = FALSE)

regioncard_title <- paste("COUNTRYNAME")
makedate <- format(Sys.time(), "%b %d %Y")

for(i in 1:3) {
  filename <- str_to_lower(str_replace_all(rownames(mtcars), " ", ""))[i]
  knit2pdf(input  = "region_card.Rnw", output = paste0("output/", filename, ".tex"), compiler = "xelatex")
  testplot <- ggplot(mtcars[i,], aes(x = cyl, y = disp) ) + geom_point()
}
