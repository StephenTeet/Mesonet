#Code for importing 1 month worth of daily 5 minute Mesonet Files
#Stephen Teet   6-19-2020

#Import necessary libraries
library(plyr)

#Set the working directory
setwd("D:/LTAR/Mesonet/2018/Jan")

#Create list of file names; thes include the date and station info, the file only includes time
#in 5 minute increments
filelist = list.files(pattern = ".*.txt")

#Clean-up file lies
datalist = lapply(filelist, FUN=read.table, skip=2, header=TRUE)

#concatenate the daily files based on the file list
df = do.call("rbind", datalist)

#read in time conversion table (5 min to time of day, e.g. 05 => 00:05)
hm = read.table("D:/LTAR/Mesonet/time.txt", header = TRUE, row.names = NULL)

#read in date table
day = read.table("D:/LTAR/Mesonet/2018/Jan_Date.txt", header = TRUE, row.names = NULL)

#pull out only needed columns from concatenated table
df = df[c(3:6,8,12:13)]

#rename column headers
df = rename(df, c("TIME"="DateTime", "RELH"="RelativeHumidity", "TAIR"="AirTemperature", "WSPD"="WindSpeed", "WDIR"="WindDirection", "RAIN"="Precipitation", "PRES"="AirPressure"))

#Add new columns do main data frame
df$LTARSiteAcronym    <- 'SP'			#add SiteAcronym
df$StationID          <- '34'     #add StationID
df$RecordType         <- 'L'      #add RecordType
df$PAR                <- ''       #add PAR
df$ShortWaveIn        <- ''       #add ShortWaveIn
df$LongWaveIn         <- ''       #add LongWaveIn
df$BatteryVoltage     <- ''       #add BatteryVoltage
df$LoggerTemperature  <- ''       #add LoggerTemperature
df$Date               <- ''       #add Date
df$Time               <- ''       #add column for time
df$TZ                 <- '-06:00' #adds time zone difference

#convert millibar to kilopascal ( /10)
df$AirPressure = df$AirPressure / 10

#get time into main table
df$Time = hm$Time

#bring date into main table
df$Date = day$Date

#concatenate date/time/tz columns into DateTime column
df$DateTime = paste0(df$Date,df$Time,df$TZ)

#reorder columns
df1 = df[,c(8,9,1,10,3,4,5,2,6,7,11,12,13,14,15)]

#get rid of error codes (optional)
df[df == -999] <- NA
df[df == -998] <- NA
df[df == -996] <- NA
df[df == -995] <- NA

#Write table as *.csv file
write.csv(df1, file = "20180100elre.csv", row.names = FALSE)#

