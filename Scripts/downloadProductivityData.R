library(httr)
library(readr)
library(dplyr)


# Set ssl_verifypper=0 since OpenStat's SSL Certificate is problematic
set_config(config(ssl_verifypeer=0))

# Openstat Volume of Production -------------------------------------------
writeLines("Downloading Volume of Production data from the Openstat API.")

POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2E/CS/0012E4EVCP0.px",
     body = '{"query": [{"code": "Ecosystem/Croptype", "selection": {"filter": "item", "values": ["0", "1", "2"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Palay-Volume-of-Production.csv") %>%
    suppressMessages() %>% suppressWarnings()


# Openstat Area Harvested -------------------------------------------------
writeLines("Downloading Area Harvested data from the Openstat API.")

POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2E/CS/0022E4EAHC0.px",
     body = '{"query": [{"code": "Ecosystem/Croptype", "selection": {"filter": "item", "values": ["0", "1", "2"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Palay-Area-Harvested.csv") %>%
    suppressMessages() %>% suppressWarnings()
