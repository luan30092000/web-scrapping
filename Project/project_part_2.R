# install.packages("tidyverse")
# install.packages("dplyr")
# install.packages("rvest")
library(tidyverse)
library(dplyr)
library(rvest)

url <- "http://www.sfu.ca/~haoluns/forecast.html"
html_source <- read_html(url)
period <- html_source %>% 
  html_nodes('.period-name') %>%
  html_text()

short_desc <- html_source %>%
  html_nodes('.short-desc') %>%
  html_text()

temp <- html_source %>%
  html_nodes('.temp') %>%
  html_text()

tbl <- tibble(period, short_desc, temp)
write.table(tbl, "301571025.csv", sep = ",", row.names = F,
            col.names =F)
