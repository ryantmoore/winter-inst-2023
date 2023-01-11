library(dplyr)
library(tidyr)
library(ggplot2)
library(sf)

# Election data from NYTimes
election <- read.csv("../results/data/election-data.csv", header = TRUE)

# Wrangling data
margin_dat <- election %>% 
      filter(Candidate %in% c("Trump", "Biden")) %>%
      mutate(Percent = as.numeric(Percent), State = tolower(State)) %>%
      group_by(State) %>%
      mutate(Total = sum(Percent)) %>%
      ungroup() %>%
      mutate(New_Pct = 100*Percent/Total) %>%
      select(State, Candidate, New_Pct) %>%
      pivot_wider(names_from = Candidate, values_from = New_Pct) %>%
      mutate(Winner = ifelse(Trump > Biden, "Red", "Blue"),
             State = replace(State, State == "D.C.", "district of columbia"))

# U.S. states map
## Map if from library(fiftystater)
fifty_states <- fiftystater::fifty_states
states_map <- st_as_sf(fifty_states, coords = c("long", "lat"), crs = 4326) %>%
  group_by(group, id) %>%
  summarise(geometry = st_combine(geometry)) %>%
  ungroup() %>% # Just in case
  st_cast("POLYGON") %>%
  st_cast("MULTIPOLYGON")

# Merge election results with map
election_map <- left_join(states_map, margin_dat, by = c("id" = "State"))

# Find state centroids
states_centroid <- states_map %>%
  group_by(id) %>%
  summarise(geometry = st_combine(geometry)) %>%
  st_point_on_surface()  
## Use built-in data set to match state.abb
states_centroid$state_abb <- state.abb[match(states_centroid$id, tolower(state.name))]

# Plot
p <- ggplot(data=election_map) +
  geom_sf(aes(fill = Winner), color = "grey50") +
  geom_sf_text(data=states_centroid, aes(label=state_abb, group=state_abb), color = "white", size = 3) +
  scale_fill_manual(values = c("#1405BD", "#DE0100")) +
  ggtitle('2020 Presidential Election Map') + 
  theme_bw() +
  theme(axis.title=element_blank(), 
        axis.text=element_blank(), 
        axis.ticks=element_blank(),
        legend.position = "none")

ggsave("../results/output/election-map-2020.png", p, width=10.5, height = 8.5)
