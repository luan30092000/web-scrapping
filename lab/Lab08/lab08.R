library(tidyverse)
library(stringr)
youthUI = read_csv("API_ILO_country_YU.csv")
youthUI <- youthUI %>% pivot_longer(c('2010':'2014'), 
                                    names_to = 'year', 
                                    values_to = 'unemployment_rate',

                                    
                                    
                                                        names_transform = list(year = as.integer))




youthDenve <- youthUI %>% filter(str_detect('Country Name',".*(IDA & IBRD.*$" ))
name <- "agentian (IDA & ABC)"
str_detect(name, "^.*(IDA & ABC.*$")
