# COVID-Research


This is a review of and some extension's to Arthur Steinmetz's exploration of COVID-19 cases and deaths, from 2020-12-23 titled [_Exploring US COVID-19 Cases and Deaths_](https://blog.rstudio.com/2020/12/23/exploring-us-covid-19-cases/).

__AS_original_code__ presents Art's original code from the blog.  See the analysis of the original code [_here_](https://github.com/hdshea/COVID-Research/blob/main/AS_original_code.md) and run up-to-date [_here_](https://github.com/hdshea/COVID-Research/blob/main/AS_code_up_to_current.md).

__JH_CSSE_Covid19_Data__ runs some simialr analyses using data from the COVID-19 Data Repository maintained by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University.  See the analyses output  [_here_](https://github.com/hdshea/COVID-Research/blob/main/JH_CSSE_Covid19_Data.md).

__collect_JH_CSSE_Covid19_Data.R__ is a script that will fully load the US Data in aggregate and by state into Data/jh_us.rdata and Data/jh_us_state.rdata, respectively.  The file .github/workflows/main.yml sets up a GitHub action that runs this script daily at 4:00am so that data are as up to date as possible.

__OWID_Covid19_Data.Rmd__ runs some similar analyses using global data from the Our World in Data organization.  See the analyses output [_here_](https://github.com/hdshea/COVID-Research/blob/main/OWID_Covid19_Data.md).
