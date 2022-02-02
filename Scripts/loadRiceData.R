library(tidyverse)
library(readxl)
library(lubridate)
library(RcppRoll)



# Download Rice Data ------------------------------------------------------
## Only run this section if the data in the Data/ folder are not updated.

#source("Scripts/updateRiceData.R")



# Data Labels -------------------------------------------------------------

source("Scripts/loadDataLabels.R")



# Rice Value of Production ------------------------------------------------
writeLines("Loading Value of Production data into R.")

AgriValue <- read_csv("Data/Openstat-Agriculture-Value-of-Production.csv") %>%
    select(Valuation = `Type of Valuation`, Subsector, contains("Q")) %>%
    mutate(across(.cols = contains("Q"), .fns = as.double)) %>%
    pivot_longer(cols = -(1:2), names_to = "Quarter", values_to = "MillionPesos") %>%
    mutate(Quarter = yq(Quarter)) %>%
    mutate(Subsector = if_else(Subsector == "CROP", "CROPS", Subsector),
           Level = case_when(str_starts(Subsector, "\\.\\.") ~ "Commodity",
                             Subsector == "AGRICULTURE" ~ "Agriculture",
                             TRUE ~ "Group"),
           Group = case_when(Level == "Group" ~ str_to_title(Subsector),
                             Level == "Agriculture" ~ "Agriculture",
                             TRUE ~ NA_character_)) %>%
    fill(Group, .direction = "down") %>%
    mutate(Level = factor(Level, levels = c("Agriculture", "Group", "Commodity")),
           Group = factor(Group, levels = c("Agriculture", "Crops", "Livestock", "Poultry", "Fisheries")),
           Subsector = str_to_sentence(str_remove(Subsector, "\\.\\."))) %>%
    suppressMessages() %>% suppressWarnings()



# Palay Productivity ------------------------------------------------------
writeLines("Loading Palay Productivity data into R.")

PalayProductivity <- full_join(
    # Volume of Production
    read_csv("Data/Openstat-Palay-Volume-of-Production.csv") %>%
        select(Crop = `Ecosystem/Croptype`, Geolocation, contains("Quarter")) %>%
        mutate(across(.cols = contains("Quarter"), .fns = as.double)) %>%
        pivot_longer(cols = contains("Quarter"), names_to = "Quarter", values_to = "MetricTons"),
    # Area Harvested
    read_csv("Data/Openstat-Palay-Area-Harvested.csv") %>%
        select(Crop = `Ecosystem/Croptype`, Geolocation, contains("Quarter")) %>%
        mutate(across(.cols = contains("Quarter"), .fns = as.double)) %>%
        pivot_longer(cols = contains("Quarter"), names_to = "Quarter", values_to = "Hectares")
) %>% left_join(GeoLabels) %>%
    select(Crop, Geolocation, Geolevel:Province, everything()) %>%
    mutate(Quarter = yq(Quarter),
           Geolevel = factor(Geolevel, levels = c("Country", "Region", "Province")),
           Region = factor(Region, levels = reglabs),
           Reg_Num = factor(Reg_Num, levels = regnums),
           TonsPerHectare = MetricTons/Hectares) %>%
    group_by(Crop, Geolocation) %>%
    # Generate Rolling 4-Quarter Averages
    mutate(MetricTons4Q = roll_meanr(MetricTons, 4),
           Hectares4Q = roll_meanr(Hectares, 4),
           TonsPerHectare4Q = roll_sumr(MetricTons, 4)/roll_sumr(Hectares, 4)) %>%
    suppressMessages() %>% suppressWarnings()



# Rice Stocks -------------------------------------------------------------
writeLines("Loading Rice Stocks data into R.")

RiceStocks <- read_csv("Data/Openstat-Rice-Stocks.csv") %>%
    mutate(across(.cols = -c(Sector, Year), .fns = as.double)) %>%
    pivot_longer(cols = -c(Sector, Year), names_to = "Month", values_to = "ThousandMetricTons") %>%
    mutate(Month =  ym(str_c(Year, str_sub(Month, 1, 3))),
           MetricTons = ThousandMetricTons*1e3, 
           Sector = str_remove(Sector, "Rice: ")) %>%
    select(Sector, Month, MetricTons) %>%
    suppressMessages() %>% suppressWarnings()



# Rice Imports and Exports ------------------------------------------------
writeLines("Loading Rice Trade data into R.")

RiceImports_All <- read_csv("Data/Openstat-Rice-Imports.csv") %>%
    mutate(Month = ym(Period),
           Imports_MT = Imports_KG/1000) %>%
    select(CommodityCode, Country, Month, Imports_MT) %>%
    suppressMessages() %>% suppressWarnings()


RiceImports_Small_Quarterly <- RiceImports_All %>%
    group_by(Quarter = yq(quarter(Month, with_year = TRUE)),
             Country = case_when(str_detect(Country, "VIET") ~ "Viet Nam",
                                 str_detect(Country, "THAI") ~ "Thailand",
                                 TRUE ~ "Others")) %>%
    summarize(Imports_MT = sum(Imports_MT, na.rm = TRUE)) %>%
    suppressMessages() %>% suppressWarnings()

RiceImports_Small_Annual <- RiceImports_All %>%
    group_by(Year = parse_date(str_sub(Month, 1, 4), "%Y"),
             Country = case_when(str_detect(Country, "VIET") ~ "Viet Nam",
                                 str_detect(Country, "THAI") ~ "Thailand",
                                 TRUE ~ "Others")) %>%
    summarize(Imports_MT = sum(Imports_MT, na.rm = TRUE)) %>%
    suppressMessages() %>% suppressWarnings()


## Rice Exports
RiceExports_All <- read_csv("Data/Openstat-Rice-Exports.csv") %>%
    mutate(Month = ym(Period),
           Exports_MT = Exports_KG/1000) %>%
    select(CommodityCode, Country, Month, Exports_MT) %>%
    suppressMessages() %>% suppressWarnings()

RiceExports_Quarterly <- RiceExports_All %>%
    group_by(Quarter = yq(quarter(Month, with_year = TRUE))) %>%
    summarize(Exports_MT = sum(Exports_MT, na.rm = TRUE))

RiceExports_Annual <- RiceExports_All %>%
    group_by(Year = parse_date(str_sub(Month, 1, 4), "%Y")) %>%
    summarize(Exports_MT = sum(Exports_MT, na.rm = TRUE))



# Generate Quarterly Supply Utilization Accounts --------------------------
writeLines("Generating Supply Utilization Accounts data from the raw datasets.")

SUA_Quarterly <- left_join(
    PalayProductivity %>%
        ungroup() %>%
        filter(Crop == "Palay", Geolocation == "PHILIPPINES") %>%
        select(Quarter, Area_HA = Hectares, Palay_MT = MetricTons),
    RiceStocks %>%
        filter(Sector == "Total Stock", year(Month) >= 1987, month(Month) %in% c(1, 4, 7, 10)) %>%
        mutate(BeginningStock_MT = MetricTons,
               EndingStock_MT = lead(MetricTons, 1, order_by = Month)) %>%
        select(Quarter = Month, BeginningStock_MT, EndingStock_MT)) %>%
    left_join(RiceImports_Small_Quarterly %>%
                  group_by(Quarter) %>%
                  summarize(Imports_MT = sum(Imports_MT, na.rm = TRUE))) %>%
    left_join(RiceExports_Quarterly) %>%
    mutate(Rice_MT = 0.654*Palay_MT,
           Seeds_MT = Area_HA*75*0.654/1000,
           Feeds_MT = Rice_MT*0.065,
           Processing_MT = Rice_MT*0.04,
           Exports_MT = if_else(is.na(Exports_MT), 0, Exports_MT),
           Imports_MT = if_else(is.na(Imports_MT), 0, Imports_MT),
           GrossSupply_MT = BeginningStock_MT + Rice_MT + Imports_MT,
           NetFood_MT = GrossSupply_MT - (Seeds_MT + Feeds_MT + Processing_MT + Exports_MT + EndingStock_MT)) %>%
    select(Quarter, BeginningStock_MT, Palay_MT, Rice_MT, Imports_MT, GrossSupply_MT,
           Area_HA, Seeds_MT, Feeds_MT, Processing_MT, Exports_MT, EndingStock_MT, NetFood_MT) %>%
    filter(Quarter <= Sys.Date() - weeks(18)) %>%
    suppressMessages() %>% suppressWarnings()

SUA_Quarterly <- SUA_Quarterly %>%
    left_join(read_csv("Data/Openstat-Population-Estimate.csv")) %>%
    mutate(across(.cols = -Quarter, .fns = ~ roll_meanr(.x, 4), .names = "{.col}4Q")) %>%
    suppressMessages() %>% suppressWarnings()

SUA_Quarterly_PC <- SUA_Quarterly %>%
    mutate(across(.cols = ends_with("MT"), .fns = ~ .x / Population_Est),
           across(.cols = ends_with("MT4Q"), .fns = ~ .x / Population_Est4Q)) %>%
    filter(Quarter >= as.Date("2000-01-01")) %>%
    suppressMessages() %>% suppressWarnings()

PopulationEstimates <- read_csv("Data/Openstat-Population-Estimate.csv")



# Rice Inflation and Prices -----------------------------------------------
writeLines("Loading Rice Inflation data into R.")

## Inflation
RiceInflation_All <- read_csv("Data/Openstat-Rice-Inflation.csv") %>%
    mutate(across(.cols = -(1:2), .fns = as.double)) %>%
    select(Geolocation, Commodity = `Commodity Description`, everything(), -contains("Ave")) %>%
    pivot_longer(cols = -(1:2), names_to = "Month", values_to = "CPI") %>%
    mutate(Month = ym(Month)) %>%
    group_by(Geolocation, Commodity) %>%
    mutate(InflationRate = CPI/lag(CPI, 12) - 1) %>%
    suppressMessages() %>% suppressWarnings()

RiceInflation_Small <- RiceInflation_All %>%
    filter(Geolocation == "PHILIPPINES") %>%
    mutate(Commodity = as_factor(str_to_title(Commodity))) %>%
    suppressMessages() %>% suppressWarnings()


writeLines("Loading Price data into R.")

## Farmgate Prices
PricesFarmgate <- read_csv("Data/Openstat-Prices-Farmgate-New.csv") %>%
    filter(str_detect(Commodity, "Other")) %>%
    select(Geolocation = `Region/Province`, Commodity, everything(), -contains("Annual")) %>%
    mutate(across(.cols = -(1:2), .fns = as.double)) %>%
    pivot_longer(cols = -(1:2), names_to = "Month", values_to = "Pesos") %>%
    mutate(Commodity = str_replace(Commodity, "\\s\\[.+\\,", "\\,"),
           Month = ym(str_sub(Month, 1, 8))) %>%
    left_join(GeoLabels) %>%
    select(Geolocation, Geolevel:Province, Commodity:Pesos) %>%
    suppressMessages() %>% suppressWarnings()

PricesFarmgate_Old <- read_csv("Data/Openstat-Prices-Farmgate-Old.csv") %>%
    filter(str_detect(Commodity, "Other")) %>%
    select(Geolocation, Commodity, everything(), -contains("Annual")) %>%
    mutate(across(.cols = -(1:2), .fns = as.double)) %>%
    pivot_longer(cols = -(1:2), names_to = "Month", values_to = "Pesos") %>%
    mutate(Commodity = str_replace(Commodity, "\\s\\[.+\\,", "\\,"),
           Month = ym(str_sub(Month, 1, 8))) %>%
    left_join(GeoLabels) %>%
    select(Geolocation, Geolevel:Province, Commodity:Pesos) %>%
    suppressMessages() %>% suppressWarnings()


## Wholesale Prices
PricesWholesale_Raw <- read_csv("Data/Openstat-Prices-Wholesale.csv") %>%
    rename(Geolocation = `Region Province`) %>%
    select(Geolocation, Commodity, everything(), -contains("Annual")) %>%
    mutate(across(.cols = -(1:2), .fns = as.double)) %>%
    pivot_longer(cols = -(1:2), names_to = "Month", values_to = "Pesos") %>%
    mutate(Month = ym(str_sub(Month, 1, 8))) %>%
    left_join(GeoLabels) %>%
    select(Geolocation, Geolevel, Region, Reg_Num, Province, Commodity, Month, Pesos) %>%
    suppressMessages() %>% suppressWarnings()

PricesWholesale_Reg <- PricesWholesale_Raw %>%
    filter(Geolevel == "Province") %>%
    group_by(Commodity, Month, Region) %>%
    summarize(Pesos = mean(Pesos, na.rm = TRUE)) %>%
    ungroup() %>%
    left_join(filter(GeoLabels, Geolevel == "Region")) %>%
    select(Geolocation, Geolevel, Region, Reg_Num, Province, Commodity, Month, Pesos) %>%
    suppressMessages() %>% suppressWarnings()

PricesWholesale_Phl <- PricesWholesale_Raw %>%
    filter(Geolocation == "PHILIPPINES") %>%
    suppressMessages() %>% suppressWarnings()

PricesWholesale <- bind_rows(PricesWholesale_Phl, PricesWholesale_Reg,
                             PricesWholesale_Raw %>% filter(Geolevel == "Province"))
rm(PricesWholesale_Raw, PricesWholesale_Reg, PricesWholesale_Phl)


## Retail Prices
PricesRetail <- read_csv("Data/Openstat-Prices-Retail-New.csv") %>%
    select(Geolocation = `Region/Province`, Commodity, everything(), -contains("Annual")) %>%
    mutate(across(.cols = -(1:2), .fns = as.double)) %>%
    pivot_longer(cols = -(1:2), names_to = "Month", values_to = "Pesos") %>%
    mutate(Month = ym(str_sub(Month, 1, 8))) %>%
    left_join(GeoLabels) %>%
    select(Geolocation, Geolevel, Region, Reg_Num, Province, Commodity, Month, Pesos) %>%
    mutate(Commodity = case_when(str_detect(Commodity, "REGULAR") ~ "Regular Milled Rice (RMR)",
                                 str_detect(Commodity, "WELL") ~ "Well Milled Rice (WMR)",
                                 str_detect(Commodity, "SPECIAL") ~ "Rice Special",
                                 TRUE ~ Commodity)) %>%
    suppressMessages() %>% suppressWarnings()

PricesRetail_Old <- read_csv("Data/Openstat-Prices-Retail-Old.csv") %>%
    select(Geolocation, Commodity, everything(), -contains("Annual")) %>%
    mutate(across(.cols = -(1:2), .fns = as.double)) %>%
    pivot_longer(cols = -(1:2), names_to = "Month", values_to = "Pesos") %>%
    mutate(Month = ym(str_sub(Month, 1, 8))) %>%
    left_join(GeoLabels) %>%
    select(Geolocation, Geolevel:Province, Commodity:Pesos) %>%
    suppressMessages() %>% suppressWarnings()


## Combining all Prices
RicePrices <- bind_rows(
    # Farmgate Prices
    bind_rows(filter(PricesFarmgate_Old, year(Month) < 2010),
              PricesFarmgate) %>% mutate(Type = "Farmgate"),
    # Wholesale Prices
    PricesWholesale %>% mutate(Type = "Wholesale"),
    # Retail Prices
    bind_rows(filter(PricesRetail_Old, year(Month) < 2012),
              PricesRetail) %>% mutate(Type = "Retail")
) %>%
    mutate(Geolevel = factor(Geolevel, levels = c("Country", "Region", "Province")),
           Region = factor(Region, reglabs),
           Reg_Num = factor(Reg_Num, regnums),
           Commodity = factor(Commodity, levels = commodities),
           Type = factor(Type, levels = c("Farmgate", "Wholesale", "Retail"))) %>%
    suppressMessages() %>% suppressWarnings()

rm(PricesFarmgate, PricesFarmgate_Old, PricesWholesale, PricesRetail, PricesRetail_Old)

save.image("appData.RData")
