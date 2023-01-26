
#Importing
library(tidyverse)
hiv = read.csv("HIVprev.csv", stringsAsFactors = TRUE) #StringsAsFactors is not necessary
hiv = select(hiv, Country, year, prevalence)

#Virtuallizing
head(hiv)
tail(hiv)
summary(hiv)
view(hiv)

#Exercise #1
  # Connect line between points
ggplot(data = hiv, mapping = aes(x = year,y = prevalence, group = Country, color = prevalence)) +
  geom_line() + geom_point() + labs(title = "Estimated HIV Prevalence 1990-2000", y = "estimated prevalence")


#Exercise #2
# Show as curves instead
ggplot(data = hiv, mapping = aes(x = year,y = prevalence, group = Country)) +
  geom_smooth(se = FALSE, alpha = 0.1) + labs(title = "Estimated HIV Prevalence 1990-2000", y = "estimated prevalence")


#Exercise #3


cc <- c("Botswana","Central African Republic","Congo","Kenya","Lesotho","Malawi",
        "Namibia","South Africa","Swaziland","Uganda","Zambia","Zimbabwe")
hihiv <- filter(hiv,Country %in% cc)

ggplot(data = hiv, aes(y = prevalence, x = year)) + 
  geom_line(aes(group = Country), color = "grey", alpha = 0.3) + 
  geom_line(aes(group = Country), data = hihiv, color = "red", alpha = 0.3) +
  geom_smooth(color = "black") +
  geom_smooth(data = hihiv, color = "red") +
  labs(title = "Estimated HIV Prevalence 1990-2000", y = "estimated prevalence", x = "year")
