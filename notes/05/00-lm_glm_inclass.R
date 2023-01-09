library(broom)
library(tidyverse)

social <- read_csv("https://bit.ly/3IzzzOt")

# Create age
social <- social %>% mutate(age = 2006 - yearofbirth)

ff <- formula(primary2006 ~ messages + age + primary2004)

# Linear Probability Model:
lm_out <- lm(ff, data = social)

tidy(lm_out)

# GLM tailored toward 0/1 outcomes:
glm_out <- glm(ff, data = social, family = binomial)

# Fitted values histogram:
hist(glm_out$fitted.values)

