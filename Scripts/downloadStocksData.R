library(httr)
library(readr)
library(dplyr)


# Openstat Rice Stocks Inventory ------------------------------------------
writeLines("Downloading Monthly Stock Invetory data from the Openstat API.")

POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2E/CS/0032E4ECNV0.px",
     body = '{"query": [{"code": "Sector", "selection": {"filter": "item", "values": ["0", "1", "2", "3"]}}],
             "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Rice-Stocks.csv") %>%
    suppressMessages() %>% suppressWarnings()
