#Lab 04

library(tidyverse)
hiv <- read.csv("HIVprevRaw.csv", stringsAsFactors = FALSE)
head(hiv)
hivcopy <- hiv

#Exercise 01: Rename column Estimated... to Country
hiv <- rename(hiv, Country = Estimated.HIV.Prevalence.....Ages.15.49.)
head(hiv)

#Exercise 02: Select every column except -(x:y)
hiv <- dplyr::select(hiv, -(X1979:X1989))

#Exercise 03: Sort data, descending of prevalence in 2011, print first 6 column
hiv <- arrange(hiv, desc = X2011)
head(hiv)

#Exercise 04: use pipe operator to chain or "pipe" data manipulation
rename(hivcopy, Country = Estimated.HIV.Prevalence.....Ages.15.49.) %>%
  select(-(X1979:X1989)) %>%
  arrange(desc(X2011))
