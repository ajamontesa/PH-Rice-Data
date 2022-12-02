library(httr)
library(readr)
library(dplyr)
library(stringr)


# Set ssl_verifypper=0 since OpenStat's SSL Certificate is problematic
set_config(config(ssl_verifypeer=0))

# Openstat Rice Inflation -------------------------------------------------
writeLines("Downloading Rice Inflation data from the Openstat API.")


full_join(
    POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/PI/CPI/2012/0012M4ACPI4.px",
         body = '{"query": [{"code": "Commodity Description",
                        "selection": {"filter": "item",
                        "values": ["0", "01.1", "01.1.11", "02.40"]}}],
                "response": {"format": "csv"}}') %>%
        content(encoding = "UTF-8"),
    POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/PI/CPI/2012/0012M4ACPI1.px",
         body = '{"query": [{"code": "Commodity Description",
                        "selection": {"filter": "item",
                        "values": ["0", "01.1", "01.1.11", "02.40"]}}],
                "response": {"format": "csv"}}') %>%
        content(encoding = "UTF-8") %>%
        mutate(Geolocation = str_remove(Geolocation, "Bansamoro\\s"))
) %>% write_csv("Data/Openstat-Rice-Inflation-2012.csv") %>%
    suppressMessages() %>% suppressWarnings()


POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2M/PI/CPI/2018/0012M4ACP09.px",
         body = '{"query": [{"code": "Commodity Description",
                        "selection": {"filter": "item",
                        "values": ["0", "2", "5", "91"]}}],
                "response": {"format": "csv"}}') %>%
        content(encoding = "UTF-8") %>%
        mutate(Geolocation = str_remove(Geolocation, "Bansamoro\\s")) %>%
    write_csv("Data/Openstat-Rice-Inflation-2018.csv") %>%
    suppressMessages() %>% suppressWarnings()
