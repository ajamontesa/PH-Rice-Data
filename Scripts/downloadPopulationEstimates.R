library(httr)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)


# Openstat National Accounts ----------------------------------------------

full_join(
	POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2B/NA/QT/1SUM/0052B5CPRQ1.px",
		 body = '{"query": [], "response": {"format": "csv"}}') %>%
		content(encoding = "UTF-8") %>%
		filter(Industry == "Gross National Income") %>%
		select(starts_with("At Current Prices")) %>%
		mutate(across(.cols = everything(), .fns = as.double)) %>%
		pivot_longer(cols = everything(), names_to = "Quarter", values_to = "GNI") %>%
		mutate(Quarter = yq(str_extract(Quarter, "\\d.+\\d")),
			   GNI = GNI*1e6),
	POST("https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2B/NA/QT/1SUM/0122B5CPCQ1.px",
		 body = '{"query": [], "response": {"format": "csv"}}') %>%
		content(encoding = "UTF-8") %>%
		filter(str_detect(Industry, "Gross National Income"),
			   str_detect(Industry, "current prices")) %>%
		select(-Industry) %>%
		mutate(across(.cols = everything(), .fns = as.double)) %>%
		pivot_longer(cols = everything(), names_to = "Quarter", values_to = "GNI_PC") %>%
		mutate(Quarter = yq(str_extract(Quarter, "\\d.+\\d")))
) %>% transmute(Quarter, Population_Est = GNI/GNI_PC) %>%
	write_csv("Data/Openstat-Population-Estimate.csv") %>%
	suppressMessages() %>% suppressWarnings()
