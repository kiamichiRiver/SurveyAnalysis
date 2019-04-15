# [Title]: Spatial Autocorrelation of Perception of Ecosystem Services in the Kiamichi Watershed
# [Author]: Kevin Neal

library(spdep)
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
                          install = T ,
                          overwrite = T)
readRenviron("~/.Renviron")                                                       # Reloads credientials to R environment

surveys <- all_surveys()                                                          # Downloads all surveys we have:
                                                                                  # Kiamichi River - mTurk
                                                                                  # Kiamichi River - Online

online.survey <- fetch_survey(surveys$id[1] ,                                     # Creates a data frame of the Online survey
                              verbose =  T ,
                              force_request = T)

mturk.survey <- fetch_survey(surveys$id[3] ,                                      # Creates a data frame of the mTurk survey
                             verbose = T , 
                             force_request = T)

### Cleaning Qualtrics data
MTurkCode <- rep("" , length(online.survey$ResponseID))                           # Creates a vector of the same length of
                                                                                  # observations as online.survey.
online.survey <- cbind(online.survey , MTurkCode)                                 # Adds that new vector to the online survey.

survey <- rbind(mturk.survey , online.survey)                                     # Now that they are the same length, we can
                                                                                  # combine both surveys together.
                                                                                  #   - online and mturk surveys
survey <- survey[c(28:length(survey$ResponseID)) ,]                               # Removes our test surveys we did.
survey <- survey[survey$Finished == 1 ,]                                          # Modifys data frame to completed surveys.
survey <- survey[survey$Q1 == "I AGREE to participate" ,]                         # Modifys data frame to people you gave consent.

# Finds out what message group the survey taker was in a puts that data in a single column.
delete.columns <- c("ResponseID"            , "ResponseSet"       , "StartDate"          , "EndDate"                     , 
                    "RO-BR-FL_15"           , "RecipientLastName" , "RecipientFirstName" , "RecipientEmail"              , 
                    "ExternalDataReference" , "RO-BR-FL_4"        , "LocationAccuracy"   , "RO-BL-Pre-Message Knowledge" ,
                    "Status"                , "Score-sum"         , "Score-weightedAvg"  , "Score-weightedStdDev"        , 
                    "MTurkCode"             , "DO-Q-Q24"          , "DO-Q-Q32"           , "DO-Q-Q33"                    , 
                    "Q43_1"                 , "Q43_2"             , "Q43_3"              , "Q43_4"                       ,
                    "Q44_1"                 , "Q44_2"             , "Q44_3"              , "Q44_4")

Message <- rep(NA , length(survey$LocationLongitude))         # Creates vector of the same length of observations in survey.

for(i in 1 : length(Message)){
  message.4 <- survey$`RO-BR-FL_4`[i]
  message.15 <- survey$`RO-BR-FL_15`[i]
  
  if(is.na(message.4) == F){
    Message[i] <- message.4
  }
  if(is.na(message.15) == F){
    Message[i] <- message.15
  }
}

survey <- cbind(survey , Message)                                           # Combines the newly created column with the survey

### Rearranging columns and changing classes
survey <- survey[, !names(survey) %in% delete.columns]                      # Removes unnessary columns
survey <- survey[, c((length(survey) - 1) , (length(survey) - 2) , 1 , length(survey) , 3:(length(survey) - 3))]

survey$Q42 <- as.character(survey$Q42)                          # These are all factor Class and cause poor output
survey$Q35 <- as.character(survey$Q35)
survey$Q39 <- as.character(survey$Q39)
survey$Q13 <- as.character(survey$Q13)

survey[is.na(survey) == T] <- 0                                 # NAs are changed to 0. Causes less trouble in life.
survey$PassFail <- rep(NA , length(survey$LocationLongitude))   # Creates a new column for Pass Fail assignments

### Looks for csv completed
past.survey <- read.csv("D:/2019_Spring/Practicum/Research/Data/qualtrics_survey.csv")

if(class(past.survey) == "data.frame"){
  survey$PassFail[1 : length(past.survey$LocationLongitude)] <- as.character(past.survey$PassFail)
  
  ip.list <- past.survey$IPAddress                               # Creates list of ip address' for past csv
  clipped.survey <- survey[!survey$IPAddress %in% ip.list ,]     # Removes completed surveys
}

### Function that assigns 'Pass' or 'Fail' to each survey based on attention questions
passFail <- function(input.survey){
  for(i in 1 : length(input.survey$LocationLongitude)){
    overturn <- ""
    row <- input.survey[i ,]
    message <- row[4]
    ip.address <- row[3]
    total = 0
    
    # Control group
    if(message == "No Message Control"){
      if(row$Q36 == 0){
        total = total + 1
      }
      if(row$Q40 == "Millard Fillmore"){
        total = total + 1
      }
      
      if(total == 0){
        print(row$Q23)
        
        overturn <- readline(prompt = '[Does this justify not getting attention questions correct (y/n)]: ')
      }
      if(total >= 1){
        input.survey$PassFail[i] <- "Pass"
      }
    }
    
    # OKC group
    if(message == "Message 1 OKC"){
      if(row$Q36 == 0){
        total = total + 1
      }
      if(row$Q42 == "The opposition attorney"){
        total = total + 1
      }
      if(row$Q40 == "Millard Fillmore"){
        total = total + 1
      }
      
      if(total < 2){
        print(row$Q23)
        
        overturn <- readline(prompt = '[Does this justify not getting attention questions correct (y/n)]: ')
      }
      if(total >= 2){
        input.survey$PassFail[i] <- "Pass"
      }
    }
    
    # Kiamichi watershed group
    if(message == "Message 2 River"){
      if(row$Q36 == 0){
        total = total + 1
      }
      if(row$Q35 == "An attorney challenging the permit"){
        total = total + 1
      }
      if(row$Q40 == "Millard Fillmore"){
        total = total + 1
      }
      
      if(total < 2){
        print(row$Q23)
        
        overturn <- readline(prompt = '[Does this justify not getting attention questions correct (y/n)]: ')
      }
      if(total >= 2){
        input.survey$PassFail[i] <- "Pass"
      }
    }
    
    if(overturn == 'y'){
      input.survey$PassFail[i] <- "Pass"                                    # Comment was substantial enough for credit
    }
    if(overturn == 'n'){
      input.survey$PassFail[i] <- "Fail"                                    # They suck for not trying, give them the boot
    }
  }
  
  return(input.survey)
}

passFail.output <- passFail(clipped.survey)
passFail.output <- passFail(survey)

clip.index.start <- length(past.survey$PassFail) + 1

survey$PassFail[clip.index.start : length(survey$PassFail)] <- as.character(passFail.output$PassFail)

### Final data.frame that we can use as a csv to avoid justifying past surveyors
write.csv(passFail.output ,
          "D:/2019_Spring/Practicum/Research/Data/qualtrics_survey.csv" ,
          row.names = F)