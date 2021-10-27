library(httr)
library(rvest)
library(dplyr)
library(stringr)
library(lubridate)



# Quarterly Rice Data -----------------------------------------------------
## Productivity Data
writeLines("Checking if Productivity Data are up to date.")
palayProdDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2E__CS/?tablelist=true&rxid=bdf9d8da-96f1-4100-ae09-18cb3eaeb313") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl01_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()
palayProdFile <- as.Date(file.mtime("Data/Openstat-Palay-Volume-of-Production.csv"))

if (palayProdDate > palayProdFile) {
	writeLines("Updating Productivity Data.")
	source("Scripts/downloadProductivityData.R")
	Sys.sleep(1)
}
writeLines("Productivity Data are up to date.")


## Value of Production Data
writeLines("Checking if Value of Production Data are up to date.")
agriProdDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2B__AA__VP/?tablelist=true") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl01_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()
agriProdFile <- as.Date(file.mtime("Data/Openstat-Agriculture-Value-of-Production.csv"))

if (agriProdDate > agriProdFile) {
	writeLines("Updating Value of Production Data.")
	source("Scripts/downloadValueOfProductionData.R")
	Sys.sleep(1)
}
writeLines("Value of Production Data are up to date.")



# Monthly Rice Data -------------------------------------------------------
## Stock Inventory
writeLines("Checking if Stocks Data are up to date.")
stocksDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2E__CS/?tablelist=true&rxid=bdf9d8da-96f1-4100-ae09-18cb3eaeb313") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl05_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()

stocksFile <- as.Date(file.mtime("Data/Openstat-Agriculture-Value-of-Production.csv"))

if (stocksDate > stocksFile) {
	writeLines("Updating Stocks Data.")
	source("Scripts/downloadStocksData.R")
	Sys.sleep(1)
}
writeLines("Stocks Data are up to date.")


## Prices Data
writeLines("Checking if Price Data are up to date.")
pricesFMDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__NFG/?tablelist=true") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl01_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()
pricesFMFile <- as.Date(file.mtime("Data/Openstat-Prices-Farmgate-New.csv"))

pricesWSDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__WS/?tablelist=true") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl01_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()
pricesWSFile <- as.Date(file.mtime("Data/Openstat-Prices-Wholesale-New.csv"))

pricesRTDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__NRP/?tablelist=true") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl01_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()
pricesRTFile <- as.Date(file.mtime("Data/Openstat-Prices-Retail-New.csv"))

if ((pricesFMDate > pricesFMFile) & (pricesWSDate > pricesWSFile) & (pricesRTDate > pricesRTFile)) {
	writeLines("Updating Prices Data.")
	source("Scripts/downloadPriceData.R")
	Sys.sleep(1)
}
writeLines("Price Data are up to date.")


## Inflation Data
writeLines("Checking if Inflation Data are up to date.")
inflationDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__PI__CPI/?tablelist=true") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl01_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()

inflationFile <- as.Date(file.mtime("Data/Openstat-Rice-Inflation.csv"))

if (inflationDate > inflationFile) {
	writeLines("Updating Inflation Data.")
	source("Scripts/downloadRiceInflationData.R")
	Sys.sleep(1)
}
writeLines("Inflation Data are up to date.")


## Trade Data
writeLines("Checking if Imports and Exports Data are up to date.")
tradeDate <- read_html("https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2L__IMT__GKI/?tablelist=true&rxid=bdf9d8da-96f1-4100-ae09-18cb3eaeb313") %>%
	html_elements(xpath = '//*[@id="ctl00_ContentPlaceHolderMain_TableList1_TableList1_LinkItemList_ctl61_pnlPx"]/text()') %>%
	html_text() %>% .[4] %>%
	str_extract("Updated:\\s+\\d+/\\d+/\\d+") %>% str_extract("\\d.+\\d") %>% mdy()

tradeFile <- as.Date(file.mtime("Data/Openstat-Rice-Imports.csv"))

if (tradeDate > tradeFile) {
	writeLines("Please update Rice Imports and Exports Data manually.")
}
writeLines("Imports and Exports Data are up to date.")


# Cleanup -----------------------------------------------------------------

rm(list = ls())
