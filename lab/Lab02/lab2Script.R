# Connect library
library(tidyverse)

# Read data and select
hiv = read.csv("HIVprev.csv", stringsAsFactors = FALSE)
hiv = select(hiv, Country, year, prevalence)

# Viewing
head(hiv)
tail(hiv)
summary(hiv)

# Exercise
#1. Plot time series of HIV prevalence by year for each country
ggplot(data = hiv, mapping = aes(x = year, y = prevalence, group_by = Country)) +
  geom_line(alpha = 0.3)

#2. "alpha" let us know that there are overlap data vitually 

#3. sub date
cc <- c("Botswana","Central African Republic","Congo","Kenya","Lesotho","Malawi", "Namibia","South Africa","Swaziland","Uganda","Zambia","Zimbabwe")
hihiv <- filter(hiv,Country %in% cc)
  #Plotting new data
ggplot(data = hiv, mapping = aes(x = year, y = prevalence, group_by = Country)) +
  geom_line(alpha = 0.3) +
  geom_line(data = hihiv, color = "red", alpha = 0.5)
