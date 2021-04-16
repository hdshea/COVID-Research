# COVID-Research

This is a review of and some extension's to Arthur Steinmetz's exploration of COVID-19 cases and deaths, from 2020-12-23 titled [_Exploring US COVID-19 Cases and Deaths_](https://blog.rstudio.com/2020/12/23/exploring-us-covid-19-cases/).

_AS_original_code_ presents Art's original code from the blog.

_JH_CSSE_Covid19_Data_ runs some simialr analyses using data from the COVID-19 Data Repository maintained by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University.

_collect_JH_CSSE_Covid19_Data.R_ is a script that will fully load the US Data in aggregate and by state into Data/jh_us.rdata and Data/jh_us_state.rdata, respectively.  The file .github/workflows/main.yml sets up a GitHub action that runs this script daily at 4:00 and 21:00 so that data are as up to date as possible.
