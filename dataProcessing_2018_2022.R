library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(stringr)

# library(haven)
# library(bcmaps)
# library(sf)
#library(gganimate)

# processing daily data from CanOSSEM

CanOSSEM_nearest_rCN_all_BC_postal_codes_2010_onwards <- readRDS( "./data/CanOSSEM_nearest_rCN_all_BC_postal_codes_2010_onwards.rds") %>%
  select(CanOSSEM_rCN, POSTAL_CODE) %>%
  distinct()

daily_data_2018_2022 <- 
  readRDS("./data/CanOSSEM_BC_estimates_2010_2022.rds")%>% 
  filter(year_val>=2018) %>%
  #  mutate(date_val=ymd(DATE)) %>%
  inner_join(.,CanOSSEM_nearest_rCN_all_BC_postal_codes_2010_onwards, 
             by = 'CanOSSEM_rCN') %>%
  rename(postalcode=POSTAL_CODE,
         smoke=predicted_pm25) %>%
  select(postalcode, date_val, smoke)


pccf_plus_conversion <- read_csv("./data/PCCFplus_7E_outputs/sampledat_out.csv") %>%
  mutate(postalcode=PCODE, HLTH_SERVICE_DLVR_AREA_CODE=str_remove(HRuid, "59")) %>%
  select(postalcode, HLTH_SERVICE_DLVR_AREA_CODE) %>%
  drop_na() %>%
  distinct()

daily_data_hsda_2018_2022 <- daily_data_2018_2022 %>% 
  left_join(pccf_plus_conversion, by = "postalcode") %>%
  drop_na() %>%
  group_by(HLTH_SERVICE_DLVR_AREA_CODE, date_val) %>%
  summarize(smoke = mean(smoke, na.rm=TRUE)) %>%
  ungroup() %>% filter(HLTH_SERVICE_DLVR_AREA_CODE!="")

saveRDS(daily_data_hsda_2018_2022, "./data/daily_hsda_lean_2018_2022.rds")

#daily_hsda <- health_hsda() %>% left_join(daily_data_hsda, by="HLTH_SERVICE_DLVR_AREA_CODE")
#saveRDS(daily_hsda, "./data/daily_hsda.rds")



