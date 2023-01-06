library(dplyr)
library(tidyr)
library(ggplot2)
library(maps)

# Election data from NYTimes
election <- read.csv("election-data.csv", header = TRUE)

# Wrangling data
margin_dat <- election %>% 
      filter(Candidate %in% c("Trump", "Biden")) %>%
      mutate(Percent = as.numeric(Percent), State = toupper(State)) %>%
      group_by(State) %>%
      mutate(Total = sum(Percent)) %>%
      ungroup() %>%
      mutate(New_Pct = 100*Percent/Total) %>%
      select(State, Candidate, New_Pct) %>%
      pivot_wider(names_from = Candidate, values_from = New_Pct) %>%
      mutate(Winner = ifelse(Trump > Biden, "Red", "Blue"),
             State = replace(State, State == "D.C.", "DISTRICT OF COLUMBIA"))

# U.S. states map
states_map <- map_data("state")
states_map$state <- toupper(states_map$region)

# Merge election results with map
election_map <- left_join(states_map, margin_dat, by = c("state" = "State"))
election_map$state_abb <- state.abb[match(election_map$state,toupper(state.name))]

# State abbreviations to centroids
snames <- aggregate(cbind(long, lat) ~ state_abb, data=election_map, FUN=function(x)mean(range(x)))

# Plot
p <- ggplot(data=election_map, aes(x=long, y=lat, group=state)) + 
  geom_polygon(aes(fill=Winner), color = "white") + 
  geom_text(data=snames, aes(label=state_abb, group=state_abb), color = "white") +
  scale_fill_manual(values = c("#1405BD", "#DE0100")) +
  ggtitle('2020 Presidential Election Map') + 
  coord_fixed(1.3) + 
  theme_bw() +
  theme(axis.title.x=element_blank(), 
        axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(),
        legend.position = "none")
 
ggsave("election-map-2020.png", p, width=10.5, height = 8.5)