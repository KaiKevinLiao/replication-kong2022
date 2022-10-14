# Compute the realized volatility of oil futures.

# First, set working directory to be the replication folder

# clear
rm(list = ls())

# package
install.packages('quantmod')
library(quantmod)

filename <- "calculations/CL1_through_36_daily.csv"

# Read in file
data <- read.csv(file=filename, header=TRUE, sep=",")
dates <- data[,1] # 1st column consists of dates
settle <- data[,-1] # The columns containing futures prices
n <- nrow(settle) # count number of rows

# Log daily returns
logreturn <- log(settle[-1,]/settle[-n,]) # ln(settle(s)/settle(s-1))
logreturn <- cbind(dates[-1],logreturn) # Attach dates to logreturn

# Read logreturn as time series
logreturn_ts <- read.zoo(logreturn)

# Rolling standard deviation
realizedvol <- rollapply(logreturn_ts, width = 252, FUN=sd, by.column = TRUE, partial = FALSE) # window = 1 year; 252 trading days in a year
# annualize the volatility
realizedvol <- realizedvol*sqrt(252) # 252 trading days in a year

# Data to export
realizedvol <- fortify.zoo(realizedvol)

# Export csv
write.csv(realizedvol, file = "calculations/CL_realizedvol.csv", row.names=FALSE)