library(httr)
library(readr)
library(dplyr)
library(stringr)


# Set ssl_verifypper=0 since OpenStat's SSL Certificate is problematic
set_config(config(ssl_verifypeer=0))

# Openstat Monthly Farmgate Prices ----------------------------------------
writeLines("Downloading Monthly Farmgate Price data from the Openstat API.")

## Old Series
POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/FG/0032M4AFP01.px",
     body = '{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["0", "1"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Prices-Farmgate-Old.csv") %>%
    suppressMessages() %>% suppressWarnings()

## New Series
POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/NFG/0032M4AFN01.px",
     body = '{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["0", "1"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Prices-Farmgate-New.csv") %>%
    suppressMessages() %>% suppressWarnings()



# Openstat Monthly Wholesale Prices ---------------------------------------
writeLines("Downloading Monthly Wholesale Price data from the Openstat API.")

# Old Series
WSPricesOld <- tibble()
for (i in 0:3) {
    WSPricesOld <- bind_rows(
        WSPricesOld,
        POST(url = "https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/WS/0052M4AWP01.px",
             body = as.character(str_c('{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["',
                                       i, '"]}}], "response": {"format": "csv"}}'))) %>%
            content(encoding = "UTF-8") %>%
            suppressMessages() %>% suppressWarnings()
    )
    Sys.sleep(0.5)
}
WSPricesOld %>% write_csv("Data/Openstat-Prices-Wholesale-Old.csv")

# New Series
WSPricesNew <- tibble()
for (i in 0:3) {
    WSPricesNew <- bind_rows(
        WSPricesNew,
        POST(url = "https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/NWS/0052M4AWA01.px",
             body = as.character(str_c('{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["',
                                       i, '"]}}], "response": {"format": "csv"}}'))) %>%
            content(encoding = "UTF-8") %>%
            suppressMessages() %>% suppressWarnings()
    )
    Sys.sleep(0.5)
}
WSPricesNew %>% write_csv("Data/Openstat-Prices-Wholesale-New.csv")

rm(WSPricesOld, WSPricesNew, i)



# Openstat Monthly Retail Prices ------------------------------------------
writeLines("Downloading Monthly Retail Price data from the Openstat API.")

## Old Series
RetailOldPrices <- tibble()
for (i in 0:3) {
    RetailOldPrices <- bind_rows(
        RetailOldPrices,
        POST(url = "https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/RP/0042M4ARP01.px",
             body = as.character(str_c('{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["',
                                       i, '"]}}], "response": {"format": "csv"}}'))) %>%
            content(encoding = "UTF-8") %>%
            suppressMessages() %>% suppressWarnings()
    )
    Sys.sleep(0.5)
}
RetailOldPrices %>% write_csv("Data/Openstat-Prices-Retail-Old.csv")

rm(RetailOldPrices, i)


## New Series 2012-based
POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/NRP/0042M4ARN01.px",
     body = '{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["0", "1", "2"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Prices-Retail-New-2012.csv") %>%
    suppressMessages() %>% suppressWarnings()


## New Series 2018-based
POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/2018/0042M4ARA01.px",
     body = '{"query": [{"code": "Commodity", "selection": {"filter": "item", "values": ["0", "1", "2"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Prices-Retail-New-2018.csv") %>%
    suppressMessages() %>% suppressWarnings()

