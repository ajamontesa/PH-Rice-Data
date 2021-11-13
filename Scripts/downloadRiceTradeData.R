library(httr)
library(readr)
library(dplyr)
library(stringr)
library(tidyr)



# Openstat Rice Imports ---------------------------------------------------
writeLines("Downloading Rice Imports data from the Openstat API.")

## Generate Codes for URL and Body of POST() request
### Note: The latest data need to be updated monthly
importCodes <- tribble(
    ~yr, ~code,
    "1991", '"176"',
    "1992", '"163"',
    "1993", str_flatten('"179", "180"'),
    "1994", str_flatten('"188", "189"'),
    "1995", str_flatten('"191", "192", "193"'),
    "1996", str_flatten('"173", "174", "175"'),
    "1997", str_flatten('"178", "179"'),
    "1998", str_flatten('"180", "181", "182"'),
    "1999", str_flatten('"197", "198", "199"'),
    "2000", str_flatten('"228", "229", "230"'),
    "2001", str_flatten('"216", "217"'),
    "2002", str_flatten('"220", "221", "222"'),
    "2003", str_flatten('"220", "221", "222", "223"'),
    "2004", str_c(str_flatten(str_c('"', 215:218, '", ')), '"219"'),
    "2005", str_c(str_flatten(str_c('"', 209:213, '", ')), '"214"'),
    "2006", str_c(str_flatten(str_c('"', 256:260, '", ')), '"261"'),
    "2007", str_c(str_flatten(str_c('"', 508:520, '", ')), '"521"'),
    "2008", str_c(str_flatten(str_c('"', 500:514, '", ')), '"515"'),
    "2009", str_c(str_flatten(str_c('"', 502:515, '", ')), '"516"'),
    "2010", str_c(str_flatten(str_c('"', 487:496, '", ')), '"497"'),
    "2011", str_c(str_flatten(str_c('"', 480:491, '", ')), '"492"'),
    "2012", str_c(str_flatten(str_c('"', 507:520, '", ')), '"521"'),
    "2013", str_c(str_flatten(str_c('"', 497:505, '", ')), '"506"'),
    "2014", str_c(str_flatten(str_c('"', 460:468, '", ')), '"469"'),
    "2015", str_c(str_flatten(str_c('"', 467:478, '", ')), '"479"'),
    "2016", str_c(str_flatten(str_c('"', 420:427, '", ')), '"428"'),
    "2017", str_c(str_flatten(str_c('"', 442:453, '", ')), '"454"'),
    "2018", str_c(str_flatten(str_c('"', 488:502, '", ')), '"503"'),
    "2019", str_c(str_flatten(str_c('"', 529:551, '", ')), '"552"'),
    "2020", str_c(str_flatten(str_c('"', 504:526, '", ')), '"527"'),
    "2021", str_c(str_flatten(str_c('"', 492:514, '", ')), '"515"')
) %>% bind_cols(url = str_c("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2L/IMT/GKI/0022L4DMK",
                            str_c(rep(c("A", "B", "C", "D"), each = 10)[1:(2021-1990)],
                                  rep(0:9, 4)[1:(2021-1990)]), ".px")) %>%
    mutate(code = str_c('{"query": [{"code": "Commodity Code", "selection": {"filter": "item", "values": [',
                        code, ']}}], "response": {"format": "csv"}}'))

## Generate Rice Imports Dataset and write as csv file
RiceImports <- tibble()
for (y in 1:(2021-1990)) {
    RiceImports <- bind_rows(
        RiceImports,
        POST(url = as.character(importCodes[y, 3]),
             body = as.character(importCodes[y, 2])) %>%
            content(encoding = "UTF-8") %>%
            pivot_longer(-c(1:2), names_to = "Period", values_to = "Imports_KG") %>%
            mutate(`Commodity Code` = as.character(`Commodity Code`),
                   Country = str_to_upper(Country),
                   Imports_KG = as.double(Imports_KG),
                   Period = str_sub(Period, 1, 8)) %>%
            select(CommodityCode = `Commodity Code`, Country, Period, Imports_KG) %>%
            suppressMessages() %>% suppressWarnings()
    )
    Sys.sleep(1)
}

RiceImports %>% write_csv("Data/Openstat-Rice-Imports.csv")



# Openstat Rice Exports ---------------------------------------------------
writeLines("Downloading Rice Exports data from the Openstat API.")

## Generate Codes for URL and Body of POST() request
### Note: The latest data need to be updated monthly
exportCodes <- tribble(
    ~yr, ~code,
    "1991", str_flatten('"160", "161"'),
    "1992", '"152"',
    "1993", '"150"',
    "1994", as.character(NA),
    "1995", as.character(NA),
    "1996", as.character(NA),
    "1997", '"134"',
    "1998", str_flatten('"133", "134", "135"'),
    "1999", str_flatten('"137", "138"'),
    "2000", '"160"',
    "2001", str_flatten('"160", "161"'),
    "2002", '"151"',
    "2003", '"163"',
    "2004", str_flatten('"164", "165"'),
    "2005", '"153"',
    "2006", str_flatten('"151", "152"'),
    "2007", str_flatten('"262", "263"'),
    "2008", str_flatten('"256", "257", "258", "259"'),
    "2009", str_c(str_flatten(str_c('"', 309:313, '", ')), '"314"'),
    "2010", str_flatten('"253", "254", "255", "256"'),
    "2011", str_c(str_flatten(str_c('"', 272:275, '", ')), '"276"'),
    "2012", str_flatten('"327", "328", "329", "330"'),
    "2013", str_c(str_flatten(str_c('"', 299:303, '", ')), '"304"'),
    "2014", str_c(str_flatten(str_c('"', 296:300, '", ')), '"301"'),
    "2015", str_c(str_flatten(str_c('"', 265:269, '", ')), '"270"'),
    "2016", str_flatten('"286", "287", "288", "289"'),
    "2017", str_c(str_flatten(str_c('"', 309:313, '", ')), '"314"'),
    "2018", str_flatten('"342", "343", "344", "345"'),
    "2019", str_c(str_flatten(str_c('"', 340:344, '", ')), '"345"'),
    "2020", str_c(str_flatten(str_c('"', 325:330, '", ')), '"331"'),
    "2021", str_c(str_flatten(str_c('"', 415:419, '", ')), '"420"'),
) %>% bind_cols(url = str_c("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2L/IMT/GKE/0012L4DXK",
                            str_c(rep(c("A", "B", "C", "D"), each = 10)[1:(2021-1990)],
                                  rep(0:9, 4)[1:(2021-1990)]), ".px")) %>%
    mutate(code = str_c('{"query": [{"code": "Commodity Code", "selection": {"filter": "item", "values": [',
                        code, ']}}], "response": {"format": "csv"}}'))

## Generate Rice Exports Dataset and write as csv file
RiceExports <- tibble()
for (y in c(1:3, 7:(2021-1990))) {
    RiceExports <- bind_rows(
        RiceExports,
        POST(url = as.character(exportCodes[y, 3]),
             body = as.character(exportCodes[y, 2])) %>%
            content(encoding = "UTF-8") %>%
            pivot_longer(-c(1:2), names_to = "Period", values_to = "Exports_KG") %>%
            mutate(`Commodity Code` = as.character(`Commodity Code`),
                   Country = str_to_upper(Country),
                   Exports_KG = as.double(Exports_KG),
                   Period = str_sub(Period, 1, 8)) %>%
            select(CommodityCode = `Commodity Code`, Country, Period, Exports_KG) %>%
            suppressMessages() %>% suppressWarnings()
    )
    Sys.sleep(1)
}

RiceExports %>% write_csv("Data/Openstat-Rice-Exports.csv")

rm(importCodes, exportCodes, RiceImports, RiceExports, y)
