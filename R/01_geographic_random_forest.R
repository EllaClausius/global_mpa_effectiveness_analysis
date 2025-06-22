# ==============================================================================
# Geographically-Weighted Random Forest model for predictions of fish biomass 
# across RLS MPA sites 
# Ella Clausius
# March 2025 
# ==============================================================================

source("R/00_packages_functions.R")

load("data/rls_biomass_grf_data.Rdata")

# Random Forest model setup ---
set.seed(456)

future::plan("multicore", 
             workers = parallel::detectCores())  

rf_split <-
  rsample::initial_split(grf_dat[, 2:ncol(grf_dat)],
                         prop = 4/5)
rf_train <-
  rsample::training(rf_split)

rf_test <-
  rsample::testing(rf_split)

coords <- 
  rf_train[ , 1:2]


# Find optimal bandwidth ---
# Using a fixed bandwidth because an adaptive bandwidth isn't ecologically meaningful
best_bw <-
  SpatialML::grf.bw(total_biomass_log ~
                      latitude+
                      longitude +
                      depth +
                      sst_mean +
                      si_mean +
                      par_mean_mean +
                      chl_mean +
                      no3_mean +
                      po4_mean +
                      kdpar_mean_mean +
                      dfe_mean +
                      phyc_mean +
                      depth_100km_mean +
                      depth_100km_range +
                      total_gravity +
                      gdp_per_capita +
                      hdi,
                    rf_train,
                    kernel = "fixed",
                    coords = coords,
                    bw.min = 5000,
                    bw.max = 150000,
                    step = 10000,
                    nthreads = 32,
                    forests = FALSE)


# Find optimal mtry ---
optim_mtry <-
  rf.mtry.optim(total_biomass_log ~
                  latitude+
                  longitude +
                  depth +
                  sst_mean +
                  si_mean +
                  par_mean_mean +
                  chl_mean +
                  no3_mean +
                  po4_mean +
                  kdpar_mean_mean +
                  dfe_mean +
                  phyc_mean +
                  depth_100km_mean +
                  depth_100km_range +
                  total_gravity +
                  gdp_per_capita +
                  hdi,
                rf_train,
                min.mtry = 1,
                max.mtry = 5,
                mtry.step = 1
  )



# ==============================================================================
# Build Geographically weighted random forest model & run final model
# ==============================================================================

final_grf_model <- 
  SpatialML::grf(total_biomass_log ~ 
                   latitude+
                   longitude + 
                   depth +
                   sst_mean +
                   si_mean +
                   par_mean_mean + 
                   chl_mean +
                   no3_mean +
                   po4_mean +
                   kdpar_mean_mean + 
                   dfe_mean + 
                   phyc_mean + 
                   depth_100km_mean + 
                   depth_100km_range +
                   total_gravity + 
                   gdp_per_capita +
                   hdi, 
                 rf_train,
                 bw = best_bw$Best.BW, 
                 ntree = 500, 
                 mtry = optim_mtry$bestTune$mtry, 
                 kernel = "fixed", 
                 forests = TRUE,    
                 coords = coords, 
                 nthreads = 32)

global_model_fit <-
  final_grf_model$Global.Model

save(global_model_fit, 
     file = "global_gwrf_model_fit.rda")

local_gwrf_model_fit <- 
  final_grf_model$LocalModelSummary

save(local_gwrf_model_fit, 
     file = "local_gwrf_model_fit.rda")


# ==============================================================================
# Predict across all sites 
# ==============================================================================


# First, test appropriate weighting parameter ---

# calculate root mean square error 
rmse <- 
  function(observed, predicted) {
    sqrt(mean((observed - predicted)^2))
  }

# calculate mean absolute error
mae <- 
  function(observed, predicted) {
    mean(abs(observed - predicted))
  }


weightings <-
  seq(0.25, 0.75, by = 0.25)

weighting_results <- NULL 

for (i in 1:length(weightings)) { 
  
  w <- weightings[i]
  
  new_dat <- rf_test %>%
    mutate(biomass_prediction = SpatialML::predict.grf(final_grf_model, 
                                                       new.data =  ., 
                                                       x.var.name = "longitude", 
                                                       y.var.name = "latitude",
                                                       local.w = w, 
                                                       global.w = 1 - w)) 
  
  weighting_results[[i]] <- 
    data.frame(local_weight = w, 
               global_weight = 1 - w,
               rmse = rmse(new_dat$total_biomass_log, 
                           new_dat$biomass_prediction),
               mae = mae(new_dat$total_biomass_log, 
                         new_dat$biomass_prediction))
  
  
}

weightings_all <- 
  do.call("rbind", weighting_results)

print(weightings_all)

min_error_w <- 
  weightings_all$local_weight[weightings_all$rmse == min(weightings_all$rmse)]
# Apply weighting factor to full dataset predictions --- 

biomass_predictions <- 
  grf_dat %>%
  mutate(biomass_prediction = SpatialML::predict.grf(final_grf_model, 
                                                     new.data =  ., 
                                                     x.var.name = "longitude", 
                                                     y.var.name = "latitude",
                                                     local.w = min_error_w, 
                                                     global.w = 1 - min_error_w)
  ) |> 
  select(rls_site_code, survey_date, biomass_prediction) 

save(biomass_predictions, 
     file = "data/processed/rls_site_biomass_predictions.Rdata")

plan(sequential)


