# Kiamichi Watershed Ecosystem Services Perception Statistial Analysis

This repository is for statistical testing on Qualtrics data. This Qualtrics data represents ecosystem services perception in the 
Kiamichi Watershed in response to water rights being sold to Oklahoma City, Oklahoma.
#

# Scripts
**[surveyLocations.R]:**
  - Downloads the qualtrics data for online surveys and mturk surveys. Plots the location of where each surveyor took their survey.
    There is a national plot and local (state of Oklahoma) plot.
  - [R Package Installation]:
      ```
      install.packages("sp")
      install.packages("rgdal")
      install.packages("gstat")
      install.packages("raster")
      install.packages("GISTools")
      install.packages("varhandle")
      install.packages("remotes")
      install.packages("snakecase")
      ```
  - [Data]: 
    * [Shapefiles](https://1drv.ms/f/s!Au6Ek2O-wSuTgbhnU8Zhh3NuTzzByw)
#
**[spatialAutocorrelation.R]:**
  - Does not exist at present
  - We will be running a spatial autocorrelation statistical analysis to evaluate how a county can influence perception on ecosystem 
    services based on political affiliation and time actively spent at political events.
  - [R Package Installation]:
    ```
    install.packages()
    ```
  - [Data]:
    * [Shapefiles](https://1drv.ms/f/s!Au6Ek2O-wSuTgbhorBXxrycpL2cuUw)
#

# Authors
  - **[CODERS]:** K. Neal, S. Bittner, L. Burkett
  - **[AUTHORSHIP]:** C. Burch, C. Anderson, S. Bittner, E. Bridge, L. Burkett, M. Busch, P. Chilson, E. Higgens, K. Neal, N. Perera
#
