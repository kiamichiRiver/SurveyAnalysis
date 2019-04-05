# [Title]: Plotting locations of survey takers to find distribution
# [Author]: Kevin Neal

library(sp)
library(rgdal)
library(gstat)
library(raster)
library(GISTools)
library(varhandle)                                 # Make sure you have this package
library(remotes)                                   # Make sure you have this package
library(snakecase)                                 # Make sure you have this package

### Fetching qualtrics surveys

# Waiting on Qualtrics API to respond to an Error Code 500
# remotes::install_github("ropensci/qualtRics")                                     # Installs qualtRics Package from GitHub
# library(qualtRics)                                                                # Loads qualtRics package to R environment
# 
# qualtrics_api_credentials(api_key = "UEOvDUXWYTtJcNqwy0SXu2qtHCCEHbNxJBYUHxDC" ,  # Loads/installs API Key and base URL to R
#                           base_url = "ousurvey.ca1.qualtrics.com" ,               # environment.
#                           install = T)
# readRenviron("~/.Renviron")                                                       # Reloads credientials to R environment
# 
# surveys <- all_surveys()                                                          # Downloads all surveys we have:
                                                                                    # Kiamichi River - mTurk
                                                                                    # Kiamichi River - Online
                                                                                    # Sample.test

# online.survey <- fetch_survey(surveys$id[1] ,                                     # Creates a data frame of the Online survey
#                               verbose = T ,                                       # with numeric values.
#                               label = F)

### Import data
survey <- read.csv("D:/2019_Spring/Practicum/Research/Data/qualtrics_apr1.csv")
us.states <- readOGR("D:/2019_Spring/Practicum/Research/Data/Shapefiles" ,
                    "us_states")
roads <- readOGR("D:/Research/Thesis/Data/Shapefiles" ,
                 "ok_roads")
watershed <- readOGR("D:/2019_Spring/Practicum/Research/Data/Shapefiles" ,
                     "kiamichi_watershed")
ok.counties <- readOGR("D:/Research/Thesis/Data/Shapefiles" ,
                       "ok_counties")

### Cleaning spatial data
us.states <- us.states[us.states$NAME_1 != "Hawaii" ,]                # Reduces shapefile to continental United States
us.states <- us.states[us.states$NAME_1 != "Alaska" ,]

study.area <- us.states[us.states$NAME_1 == "Oklahoma" ,]             # Reduces shapefile to only Oklahoma

okc.counties <- c("Cleveland" , "Canadian" , "Oklahoma")              # Creates a list of counties for OKC and Tulsa
tulsa.counties <- c("Creek" , "Okmulgee" , "Osage" ,                  # metro area (US Census).
                    "Pawnee" , "Rogers" , "Tulsa" , "Wagoner")

okc <- ok.counties[ok.counties$NAME %in% okc.counties ,]              # Creates shapefiles of OKC and Tulsa.
tulsa <- ok.counties[ok.counties$NAME %in% tulsa.counties ,]          # If the NAME is in the list, that county will
                                                                      # be added to the SpatialPolygonsDataFrame

watershed.test <- spTransform(watershed , crs(us.states))             # Reprojects the watershed to the states shapefile

### Getting only completed surveys and cleaning header data
survey <- survey[3 : length(survey$LocationLatitude), ]               # Takes away the top 3 rows (Describing text)
survey <- survey[, c(15:14 , 1:13 , 16:length(survey))]               # Moving latitude and longitude to first two columns
survey <- survey[survey$Progress == 100 ,]                            # Modifys data frame to exclude all surveys that are
                                                                      # not completed.

survey$LocationLongitude <- unfactor(survey$LocationLongitude)        # Removes factor class from both columns and converts
survey$LocationLatitude <- unfactor(survey$LocationLatitude)          # to numeric format. Loses precision but gives an 
                                                                      # accurate enough location.

### Creating a spatial data frame
crs.nad83 <- crs(study.area)                                          # Saves coordinate system to crs.nad83

survey.spdf <- SpatialPointsDataFrame(survey[, c(1:2)] ,              # Creates a SpatialPointsDataFrame with the same
                                      survey ,                        # projection/coordiante system as our states shapefile.
                                      proj4string = crs.nad83)
ok.survey.spdf <- survey.spdf[study.area ,]                           # Clips our SpatialPointsDataFrame to the state of 
                                                                      # Oklahoma.


### Plotting the distribution of survey takers
plot(us.states ,
     main = "Kiamichi River Survey Distribution")
plot(roads , 
     add = T)
plot(survey.spdf , 
     pch = 16 , 
     col = "red" ,
     add = T)

plot(study.area ,
     main = "Kiamichi River Survey Distribution")
plot(okc ,
     col = "yellow" ,
     add = T)
plot(tulsa , 
     col = "yellow" ,
     add = T)
plot(watershed.test ,
     col = "green" ,
     add = T)
plot(survey.spdf , 
     pch = 16 , 
     col = "red" ,
     add = T)









