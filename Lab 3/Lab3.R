
library(tidyverse)
hiv = read.csv("HIVprev.csv", stringsAsFactors = TRUE)
hiv = select(hiv, Country, year, prevalence)
head(hiv)
tail(hiv)
summary(hiv)
view(hiv)

#Exercise #1
# Connect line between points
ggplot(data = hiv, mapping = aes(x = year,y = prevalence, group_by = Country)) +
  geom_line() + geom_point() +labs(title = "Estimated HIV Prevalence 1990-2000", y = "estimated prevalence")

#Exercise #2
# Show as curves instead
ggplot(data = hiv, mapping = aes(x = year,y = prevalence, group_by = Country)) +
  geom_smooth(color = "blue", se = FALSE) + labs(title = "Estimated HIV Prevalence 1990-2000", y = "estimated prevalence")

#Exercise #3
cc <- c("Botswana","Central African Republic","Congo","Kenya","Lesotho","Malawi",
        "Namibia","South Africa","Swaziland","Uganda","Zambia","Zimbabwe")
hihiv <- filter(hiv,Country %in% cc)
ggplot(data = hiv, mapping = aes(y = prevalence, x = year, group_by = Country)) + 
  geom_smooth(color = "grey", se = FALSE, alpha = 0.3) +
  geom_smooth(data = hihiv, color = "red", se = FALSE, alpha = 0.3)

