library(tidyverse)
library(tidyr)
hiv <- read_csv("HIVprevRaw.csv")
spec(hiv)
hiv <- hiv %>% 
  rename(Country = colnames(hiv)[1]) %>%
  select(-("1979":"1989"))

hiv <- hiv %>% 
  pivot_longer(colnames(hiv)[-1], names_to = "Year", values_to = "Prevalence") %>% 
  arrange(Country, Year)
is.tibble(hiv)
