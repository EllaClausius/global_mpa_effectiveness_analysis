# ==============================================================================
# Predict global shallow reef encompassing MPA effectiveness under 4 scenarios
# Ella Clausius 
# March 2025
# ==============================================================================

source("R/00_packages_functions.R")

# Data import ---

# Load MPA Random Forest model 
#source("R/mpa_random_forest.R")
load("data/processed/final_mpa_rf.rda")

# load Protected Seas zone-level data for predictions 
load("data/protected_seas_zones.Rdata")

# Status Quo Scenario ---
## Low compliance 
s1_low <- 
  protected_seas_zones %>%
  mutate(compliance = 1, 
         scenario = "Status Quo") 

s1_low$pred_effect_size <-
  predict(final_model_mpa, s1_low)$.pred

## High compliance 
s1_high <-
  protected_seas_zones %>%
  mutate(compliance = 3, 
         scenario = "Status Quo") 

s1_high$pred_effect_size <-
  predict(final_model_mpa, s1_high)$.pred

# Fully protected Scenario --- 
## Low compliance 
s2_low <- 
  protected_seas_zones %>%
  mutate(compliance = 1, 
         level_fishing_protection = 5, 
         scenario = "Fully Protected") 

s2_low$pred_effect_size <- 
  predict(final_model_mpa, s2_low)$.pred

## High compliance 
s2_high <-
  protected_seas_zones %>%
  mutate(compliance = 3, 
         level_fishing_protection = 5, 
         scenario = "Fully Protected") 

s2_high$pred_effect_size <-
  predict(final_model_mpa, s2_high)$.pred


# Old Scenario ---
## Low compliance 
s3_low <- 
  protected_seas_zones %>%
  mutate(compliance = 1, 
         mpa_age = pmax(mpa_age, 20),
         scenario = "Old") 

s3_low$pred_effect_size <- 
  predict(final_model_mpa, s3_low)$.pred

## High compliance 
s3_high <- 
  protected_seas_zones %>%
  mutate(compliance = 3, 
         mpa_age = pmax(mpa_age, 20), 
         scenario = "Old") 

s3_high$pred_effect_size <- 
  predict(final_model_mpa, s3_high)$.pred


#Fully Protected & Old scenario ---
## Low compliance 
s4_low <-
  protected_seas_zones %>%
  mutate(compliance = 1, 
         level_fishing_protection = 5, 
         mpa_age = pmax(mpa_age, 20), 
         scenario = "Fully Protected & Old") 

s4_low$pred_effect_size <- 
  predict(final_model_mpa, s4_low)$.pred

## High compliance
s4_high <- 
  protected_seas_zones %>%
  mutate(compliance = 3, 
         level_fishing_protection = 5, 
         mpa_age = pmax(mpa_age, 20), 
         scenario = "Fully Protected & Old") 

s4_high$pred_effect_size <- 
  predict(final_model_mpa, s4_high)$.pred


# Combine all scenarios ---
mpa_scenarios <- 
  rbind(s1_low, 
        s1_high, 
        s2_low, 
        s2_high, 
        s3_low,
        s3_high, 
        s4_low, 
        s4_high) |> 
  select(zone_id, 
         network_id, 
         scenario, 
         compliance, 
         pred_effect_size, 
         zone_marine_area_km) |> 
  mutate(compliance = case_when(compliance == 1 ~ "Low", 
                                TRUE ~ "High"))

save(mpa_scenarios, 
     file = "data/processed/global_mpa_effectiveness_scenarios.Rdata")