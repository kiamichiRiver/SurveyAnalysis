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
remotes::install_github("ropensci/qualtRics")                                     # Installs qualtRics Package from GitHub
library(qualtRics)                                                                # Loads qualtRics package to R environment

qualtrics_api_credentials(api_key = "UEOvDUXWYTtJcNqwy0SXu2qtHCCEHbNxJBYUHxDC" ,  # Loads/installs API Key and base URL to R
                          base_url = "ousurvey.ca1.qualtrics.com" ,               # environment.
                          install = T)
readRenviron("~/.Renviron")                                                       # Reloads credientials to R environment

surveys <- all_surveys()                                                          # Downloads all surveys we have:
                                                                                  # Kiamichi River - mTurk
                                                                                  # Kiamichi River - Online

online.survey <- fetch_survey(surveys$id[1] ,                                     # Creates a data frame of the Online survey
                              verbose =  T ,
                              force_request = T)

mturk.survey <- fetch_survey(surveys$id[2] ,                                      # Creates a data frame of the mTurk survey
                             verbose = T ,
                             force_request = T)

MTurkCode <- rep("" , length(online.survey$ResponseID))                           # Creates a vector of the same length of
                                                                                  # observations as online.survey
online.survey <- cbind(online.survey , MTurkCode)                                 # Adds that new vector to the online survey

survey <- rbind(mturk.survey , online.survey)                                     # Now that they are the same length, we can
                                                                                  # combine both surveys together
                                                                                  #   - online and mturk surveys
survey <- survey[, c(114:113 , 1:112 , length(survey))]                           # Moves lat/long to first two columns
survey <- survey[survey$Finished == 1 ,]                                          # Modifys data frame to completed surveys

### Import data
us.states <- readOGR("D:/2019_Spring/Practicum/Research/Data/Shapefiles" ,
                    "us_states")
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
plot(ok.survey.spdf , 
     pch = 16 , 
     col = "red" ,
     add = T)