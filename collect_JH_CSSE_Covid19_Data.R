library(tidyverse)
library(rvest)
library(timetk)
library(lubridate)
library(broom)
library(knitr)
library(httr)

csse_raw <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us"
csse_dir <- "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports_us"
exclusions <- c("Diamond Princess", "Grand Princess" , "American Samoa", "Guam", "Northern Mariana Islands", "Recovered",
                "Virgin Islands", "Puerto Rico")
col_names <- c("State", "Country", "Date", "Lat", "Long_", "Confirmed", "Deaths", "Recovered", "Active", "FIPS",
               "Incident_Rate", "Total_Test_Results", "People_Hospitalized", "Case_Fatality_Ratio", "UID", "ISO3",
               "Testing_Rate", "Hospitalization_Rate")
col_classes <- c("character", "character", "Date", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                 "numeric", "numeric", "numeric", "numeric", "numeric", "character",
                 "numeric", "numeric")

# This is unsatisfying, but it works - extract data file names from CSSE GitHub site
req <- GET(csse_dir)
stop_for_status(req)
fname <- tempfile(fileext = ".txt")
write_file(req$content, fname)
file_names <- tibble(text = readLines(fname)) %>%
  filter(str_detect(text,".csv")) %>%
  mutate(text = str_match(str_match(str_trim(text),"title=\"[1234567890-]*.csv\""),"[1234567890-]*.csv"))
unlink(fname)

for(idx in seq_along(file_names$text)) {
  if(idx == 1) {
    us_states <- tibble(read.csv(paste(csse_raw, file_names[idx,], sep = "/"), col.names = col_names, colClasses = col_classes)) %>%
      filter(!(State %in% exclusions)) %>%
      select(-Country, -FIPS, -UID, -ISO3, -People_Hospitalized, -Hospitalization_Rate)
  } else {
    new_date <- tibble(read.csv(paste(csse_raw, file_names[idx,], sep = "/"), col.names = col_names, colClasses = col_classes)) %>%
      filter(!(State %in% exclusions)) %>%
      select(-Country, -FIPS, -UID, -ISO3, -People_Hospitalized, -Hospitalization_Rate)

    us_states <- rbind(us_states, new_date)
  }
}

# Create rolling average changes
us_states <- us_states %>%
  mutate(State = as_factor(State)) %>%
  arrange(State, Date) %>%
  group_by(State) %>%
  mutate(
    Confirmed_7 = (Confirmed - lag(Confirmed, 7)) / 7,
    Deaths_7 = (Deaths - lag(Deaths, 7)) / 7,
    Recovered_7 = (Recovered - lag(Recovered, 7)) / 7,
    Active_7 = (Active - lag(Active, 7)) / 7,
    Incident_Rate_7 = (Incident_Rate - lag(Incident_Rate, 7)) / 7,
    Case_Fatality_Ratio_7 = (Deaths_7 * 100) / Confirmed_7,
    Testing_Rate_7 = (Testing_Rate - lag(Testing_Rate, 7)) / 7
  )

#Create a national aggregate data set
us <- us_states %>%
  select(-Lat, -Long_) %>%
  group_by(Date) %>%
  summarize(across(
    .cols = where(is.double),
    .fns = function(x) sum(x),
    .names = "{col}"
  ))

#Output data sets to saved files
save(us_states, file = "Data/jh_us_states.rdata")
save(us, file = "Data/jh_us.rdata")

