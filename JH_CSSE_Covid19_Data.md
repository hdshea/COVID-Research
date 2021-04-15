Exploring US COVID-19 Cases and Deaths - Johns Hopkins CSSE Data Sets
================
H. David Shea
2021-02-12

## Johns Hopkins CSSE COVID-19 Data

### Field description

-   State - The name of the State within the USA.
-   Date - The most recent date the file was pushed.
-   Lat - Latitude.
-   Long\_ - Longitude.
-   Confirmed - Aggregated case count for the state.
-   Deaths - Aggregated death toll for the state.
-   Recovered - Aggregated Recovered case count for the state.
-   Active - Aggregated confirmed cases that have not been resolved
    (Active cases = total cases - total recovered - total deaths).
-   Incident\_Rate - cases per 100,000 persons.
-   Total\_Test\_Results - Total number of people who have been tested.
-   Case\_Fatality\_Ratio - Number recorded deaths \* 100/ Number
    confirmed cases.
-   Testing\_Rate - Total test results per 100,000 persons. The “total
    test results” are equal to “Total test results (Positive +
    Negative)” from COVID Tracking Project.

``` r
# source https://github.com/CSSEGISandData/COVID-19

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
rm(req, fname, csse_dir)

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
rm(file_names, csse_raw, exclusions, col_names, col_classes, idx, new_date)
save(us_states, file = "jh_us_states.rdata")

us_states[10:20,] %>% kable()
```

| State     | Date       |     Lat |    Long\_ | Confirmed | Deaths | Recovered |  Active | Incident\_Rate | Total\_Test\_Results | Case\_Fatality\_Ratio | Testing\_Rate |
|:----------|:-----------|--------:|----------:|----------:|-------:|----------:|--------:|---------------:|---------------------:|----------------------:|--------------:|
| Florida   | 2021-01-02 | 27.7663 |  -81.6868 |   1323315 |  21673 |        NA | 1301642 |       6161.333 |             15703599 |             1.6377809 |      73115.71 |
| Georgia   | 2021-01-02 | 33.0406 |  -83.6431 |    677589 |  10958 |        NA |  666631 |       6381.859 |              5401054 |             1.6172045 |      50869.73 |
| Hawaii    | 2021-01-02 | 21.0943 | -157.4983 |     22397 |    289 |     11958 |    9775 |       1555.367 |               816811 |             1.3123240 |      57689.61 |
| Idaho     | 2021-01-02 | 44.2405 | -114.4788 |    141077 |   1436 |     58649 |   80992 |       7894.341 |               545485 |             1.0178839 |      30524.07 |
| Illinois  | 2021-01-02 | 40.3495 |  -88.9861 |    963389 |  17978 |        NA |  945411 |       7602.609 |             13374665 |             1.8661205 |     105546.51 |
| Indiana   | 2021-01-02 | 39.8494 |  -86.2583 |    517773 |   9468 |    345474 |  163928 |       7690.971 |              5730043 |             1.6167317 |      85113.73 |
| Iowa      | 2021-01-02 | 42.0115 |  -93.2105 |    282980 |   3898 |    241229 |   37853 |       8969.056 |              1174406 |             1.3774825 |      37222.82 |
| Kansas    | 2021-01-02 | 38.5266 |  -96.7265 |    230108 |   2872 |      4612 |  222819 |       7905.190 |              1012506 |             1.2470528 |      34754.44 |
| Kentucky  | 2021-01-02 | 37.6681 |  -84.6701 |    265261 |   2623 |     36740 |  225898 |       5937.341 |              3148606 |             0.9888374 |      70475.30 |
| Louisiana | 2021-01-02 | 31.1695 |  -91.8678 |    315275 |   7488 |    263712 |   44075 |       6781.866 |              4214182 |             2.3750694 |      90651.08 |
| Maine     | 2021-01-02 | 44.6939 |  -69.3819 |     24902 |    352 |     11374 |   13176 |       1852.535 |              1111413 |             1.4135411 |      82681.38 |

# Exploratory Data Analyses

``` r
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
    Case_Fatality_Ratio_7 = (Deaths_7 *100) / Confirmed_7,
    Testing_Rate_7 = (Testing_Rate - lag(Testing_Rate, 7)) / 7
  )

#Create a national aggregate data set
us <- us_states %>%
  select(-Lat, -Long_) %>% 
  group_by(Date) %>%
  summarize(across(
    .cols = where(is.double),
    .fns = function(x) sum(x, na.rm = T),
    .names = "{col}"
  ))

us[10:20,] %>% kable()
```

| Date       | Confirmed | Deaths | Recovered | Active | Incident\_Rate | Total\_Test\_Results | Case\_Fatality\_Ratio | Testing\_Rate | Confirmed\_7 | Deaths\_7 | Recovered\_7 | Active\_7 | Incident\_Rate\_7 | Case\_Fatality\_Ratio\_7 | Testing\_Rate\_7 |
|:-----------|----------:|-------:|----------:|-------:|---------------:|---------------------:|----------------------:|--------------:|-------------:|----------:|-------------:|----------:|------------------:|-------------------------:|-----------------:|
| 2020-04-21 |    810919 |  44829 |     57944 | 765842 |       10985.98 |              4165536 |              193.7064 |      76370.48 |     29172.71 |  2665.286 |     2526.571 | 26460.000 |          431.6829 |                 303.6765 |         2770.532 |
| 2020-04-22 |    839453 |  47019 |     61341 | 792063 |       11449.95 |              4479542 |              199.2584 |      79942.63 |     29134.43 |  2623.000 |     2575.143 | 26472.000 |          445.1043 |                 314.2237 |         2870.605 |
| 2020-04-24 |    868081 |  50339 |     63362 | 817523 |       11949.32 |              4673945 |              203.5220 |      83184.88 |     28763.43 |  2446.429 |     2482.571 | 26281.143 |          453.5218 |                 326.9682 |         2981.116 |
| 2020-04-25 |    904419 |  52352 |     81282 | 851837 |       12503.24 |              4954645 |              204.7622 |      88630.40 |     29380.00 |  2180.857 |     2671.857 | 27179.571 |          461.8875 |                 323.4350 |         3365.014 |
| 2020-04-26 |    937348 |  54158 |     90255 | 882826 |       13009.55 |              5200442 |              204.7896 |      93249.08 |     29451.57 |  2168.000 |     3145.286 | 27242.286 |          465.8642 |                 322.2446 |         3643.119 |
| 2020-04-27 |    964588 |  55347 |     90811 | 909265 |       13474.33 |              5456542 |              204.8042 |      97844.14 |     29523.43 |  2047.429 |     2898.286 | 27476.571 |          475.6626 |                 331.8864 |         3892.407 |
| 2020-04-28 |    987150 |  56770 |     94555 | 930176 |       13833.92 |              5608667 |              205.6452 |     100727.60 |     29132.57 |  2037.286 |     2978.571 | 27068.286 |          469.4127 |                 340.3278 |         3873.259 |
| 2020-04-29 |   1011653 |  58849 |    139107 | 952563 |       14246.69 |              5814313 |              208.3075 |     104294.87 |     28676.29 |  2002.857 |     6807.571 | 26674.429 |          465.8167 |                 327.3015 |         3989.199 |
| 2020-04-30 |   1039128 |  61354 |    147291 | 977245 |       14663.77 |              6047609 |              212.0701 |     109072.03 |     28525.00 |  2047.857 |     6951.571 | 26454.571 |          459.1173 |                 317.9007 |         4161.343 |
| 2020-05-01 |   1068487 |  63250 |    153753 | 850865 |       15158.23 |              6253903 |              214.5531 |     112977.88 |     28629.43 |  1844.429 |     6833.714 |  4763.143 |          458.4149 |                 304.2832 |         4256.143 |
| 2020-05-02 |   1102673 |  65210 |    163821 | 872853 |       15764.37 |              6575332 |              214.4552 |     118296.57 |     28322.00 |  1836.857 |     7548.286 |  3002.286 |          465.8762 |                 302.0268 |         4238.024 |
