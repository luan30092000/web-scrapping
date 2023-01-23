# Connect library
library(tidyverse)

# Read data and select
hiv = read.csv("HIVprev.csv", stringAsFactors = FALSE)
hiv = select(hiv, Country, year, prevalence)

# View
head(hiv)
tail(hiv)
summary(hiv)

# Plotting
ggplot(data = hiv, mapping = aes(x = year, y= prevalence, group = Country, alpha = Country)) + geom_line()
    

# filter data   
cc <- c("Botswana","Central African Republic","Congo","Kenya","Lesotho","Malawi",
        "Namibia","South Africa","Swaziland","Uganda","Zambia","Zimbabwe")
hihiv <- filter(hiv,Country %in% cc)

# Plotting new data
ggplot(data = hihiv, mapping = aes(x = year, y= prevalence, group = Country, alpha = Country, color = Country)) + geom_line()

