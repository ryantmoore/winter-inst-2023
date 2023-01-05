library(here)
library(tidyverse)
load(here("data", "laws.RData"))
laws2 <- laws %>% unite(date,
                        starts_with("statute"),
                        sep = "-")
laws3 <- laws2 %>% separate(section,
                   into = c("section", "subsection"),
                   convert = TRUE)
laws4 <- laws3 %>%
  gather(starts_with("author"),
                 key = author,
                 value = wrote_bill) %>%
  dplyr::filter(wrote_bill == "yes") %>%
  select(-wrote_bill)
laws4$date <- parse_date(laws4$date, "%Y-%b-%d")
