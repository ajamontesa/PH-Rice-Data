# **Philippine Rice Data**
  

## **Scripts**
The `Scripts/` folder contains R scripts which can be run using the `source()` function in R:  
-  Run `downloadPriceData.R` to download monthly price data from PSA's OpenStat platform and save .csv files to the `Data/` folder.
-  Run `downloadProductivityData.R` to download quarterly volume of production and area harvested data from PSA's OpenStat platform and save .csv files to the `Data/` folder.
-  Run `downloadRiceInflationData.R` to download monthly inflation data from PSA's OpenStat platform and save .csv files to the `Data/` folder.
-  Run `downloadRiceTradeData.R` to download monthly rice imports and exports data from PSA's OpenStat platform and save .csv files to the `Data/` folder.
-  Run `downloadStocksData.R` to download monthly rice stocks inventory data from PSA's OpenStat platform and save .csv files to the `Data/` folder.
-  Run `downloadValueOfProductionData.R` to download quarterly production value data from PSA's OpenStat platform and save .csv files to the `Data/` folder.
-  Run `loadRiceData.R` to load the locally saved data sets files into R.

  
## **Datasets**
Rice datasets are stored inside the `Data/` folder.  
-  Files named using the format `Openstat-<dataset>.csv` are datasets scraped from the PSA OpenStat platform.
-  Other manually extracted or compiled data sets are stored in respective subfolders or files.
  
  
### **OpenStat Data**
These are datasets which can be programmatically extracted from OpenStat.

| Dataset | Period | URL | File in `Data/` Folder |
| ------- | :----: | --- | ---------------------- |
| Value of Production in Agriculture | 2000 - present<br/>(Quarterly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2B__AA__VP/0012B5FVOP1.px/ | `Opentstat-Agriculture-Value-of-Production.csv` |
| Palay Volume of Production | 1987 - present<br/>(Quarterly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2E__CS/0012E4EVCP0.px/ | `Openstat-Palay-Volume-of-Production.csv` |
| Palay Area Harvested | 1987 - present<br/>(Quarterly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2E__CS/0022E4EAHC0.px/ | `Openstat-Palay-Area-Harvested.csv` |
| Rice Monthly Stocks Inventory | 1980 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2E__CS/0032E4ECNV0.px/ | `Openstat-Rice-Stocks.csv` |
| Gross Kilos of Imports | 1991 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2L__IMT__GKI/?tablelist=true | `Openstat-Rice-Imports.csv` |
| Gross Kilos of Exports | 1991 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2L__IMT__GKE/?tablelist=true | `Openstat-Rice-Exports.csv` |
| Supply Utilization Accounts | 1990 - present<br/>(Annual) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2B__AA__SU/0012B5FSUA0.px/ | A quarterly data set is generated using the local saved data sets. |
| Consumer Price Index | 1994 - 2011;<br/>2012 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__PI__CPI/?tablelist=true | `Openstat-Rice-Inflation.csv` |
| Farmgate Prices (Old Series) | 1990 - 2020<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__FG/0032M4AFP01.px/ | `Openstat-Prices-Farmgate-Old.csv` |
| Farmgate Prices (New Prices) | 2010 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__NFG/0032M4AFN01.px/ | `Openstat-Farmgate-Prices-New.csv` |
| Wholesale Prices | 1990 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__WS/0052M4AWP01.px/ | `Openstat-Prices-Wholesale.csv` |
| Retail Prices (Old Series) | 1990 - 2020<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__RP/0042M4ARP01.px/ | `Openstat-Prices-Retail-Old.csv` |
| Retail Prices (New Series) | 2012 - present<br/>(Monthly) | https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__2M__NRP/0042M4ARN01.px/ | `Openstat-Prices-Retail-New.csv` |

<br/>  

### **Manually Extracted and Compiled Data**
| Dataset | Period | Source | Folder / File |
| ------- | :----: | ------ | ------------- |
| Weekly Palay and Rice Prices | 2007 - 2020<br/>(Weekly) | https://psa.gov.ph/content/updates-palay-rice-and-corn-prices-0 | `PSA-Weekly-Prices-Discontinued.xlsx` |
| NFA Procurement and Distribution Data | 2014 - present<br/>(Monthly) | https://nfa.gov.ph/transparency/accomplishment-report/monthly-accomplishment-report<br/>https://nfa.gov.ph/transparency/accomplishment-report/annual-accomplishment-report | `NFA-Procurement-Distribution.xlsx` |
| International Rice Prices | 2000 - present<br/>(Monthly) | https://fpma.apps.fao.org/giews/food-prices/tool/public/#/dataset/international | `UNFAO-International-Rice-Prices.xlsx` |