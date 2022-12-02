library(httr)
library(readr)
library(dplyr)


# Set ssl_verifypper=0 since OpenStat's SSL Certificate is problematic
set_config(config(ssl_verifypeer=0))

# Openstat Value of Production in Agriculture -----------------------------
writeLines("Downloading Value of Production data from the Openstat API.")

POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2B/AA/VP/NA/0012B5FVOP1.px",
     body = '{"query": [], "response": {"format": "csv"}}') %>%
    content(encoding = "UTF-8") %>%
    write_csv("Data/Openstat-Agriculture-Value-of-Production.csv") %>%
    suppressMessages() %>% suppressWarnings()
