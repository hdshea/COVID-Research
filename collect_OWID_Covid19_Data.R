library(tidyverse)

# OWID Corona Virus data
owid_full_metadata_url <- "https://covid.ourworldindata.org/data/owid-covid-codebook.csv"
owid_full_dataset_url <- "https://covid.ourworldindata.org/data/owid-covid-data.csv"

# Get metadata
owid_full_metadata <- tibble(read.csv(owid_full_metadata_url))

# Get the actual data
owid_full_dataset <- tibble(read.csv(owid_full_dataset_url)) %>%
  mutate(date = as.Date(date)) %>%
  arrange(location, date)

top_50_pop <- owid_full_dataset %>%
  filter(date == (max(unique(owid_full_dataset$date)) - 1)) %>%
  filter(!str_starts(iso_code, "OWID")) %>%
  arrange(desc(population)) %>%
  filter(row_number() <= 50) %>%
  pull(location)

top_6_change_cases <- owid_full_dataset %>%
  filter(date >= (max(unique(owid_full_dataset$date)) - 35)) %>%
  filter(location %in% top_50_pop) %>%
  mutate(
    cases_change = round(total_cases / lag(total_cases, 30), 2),
    deaths_change = round(total_deaths / lag(total_deaths, 30),2)
    ) %>%
  filter(date == (max(unique(owid_full_dataset$date)) - 1)) %>%
  select(location, date, cases_change, deaths_change) %>%
  arrange(desc(cases_change)) %>%
  filter(row_number() <= 6)

top_6_change_deaths <- owid_full_dataset %>%
  filter(date >= (max(unique(owid_full_dataset$date)) - 35)) %>%
  filter(location %in% top_50_pop) %>%
  mutate(
    cases_change = total_cases / lag(total_cases, 30),
    deaths_change = total_deaths / lag(total_deaths, 30)
  ) %>%
  filter(date == (max(unique(owid_full_dataset$date)) - 1)) %>%
  select(location, date, cases_change, deaths_change) %>%
  arrange(desc(deaths_change)) %>%
  filter(row_number() <= 6)

owid_full_dataset %>%
  filter(location %in% (top_6_change_cases %>% pull(location))) %>%
  ggplot(aes(date, new_cases_smoothed / 1000)) +
  geom_line() +
  facet_wrap(~location, scales = "free") +
  theme(legend.position = "bottom") +
  labs(
    title = "Cases by Region",
    caption = "Source:  Our World in Data",
    x = "Date",
    y = "7-Day Smoothed Cases (000)"
  )

owid_full_dataset %>%
  filter(location %in% (top_6_deaths_cases %>% pull(location))) %>%
  ggplot(aes(date, new_deaths_smoothed)) +
  geom_line() +
  facet_wrap(~location, scales = "free") +
  theme(legend.position = "bottom") +
  labs(
    title = "Deaths by Region",
    caption = "Source:  Our World in Data",
    x = "Date",
    y = "7-Day Smoothed Deaths"
  )

