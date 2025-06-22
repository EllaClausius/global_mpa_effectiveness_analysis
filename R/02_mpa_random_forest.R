# ==============================================================================
# Random Forest model of RLS MPA effect sizes
# Ella Clausius 
# March 2025
# ==============================================================================

source("R/00_packages_functions.R")

# Load in RLS site-level biomass predictions 
load("data/processed/rls_site_biomass_predictions.Rdata")

# Load RLS site-level MPA data 
load("data/rls_mpa_data.Rdata")


# 
rf_dat <- 
  rls_mpa_data |> 
  left_join(biomass_predictions) |> 
  mutate(effect_size = total_biomass_log - biomass_prediction) |> 
  select(effect_size, 
         level_fishing_protection, 
         zone_marine_area_km, 
         mpa_age, 
         compliance
         )


# ==============================================================================
# Run Random Forest model 
# ==============================================================================

# Set up parallel processing 
# plan(multicore, 
#      workers = parallel::detectCores() - 1)  

set.seed(123)
rf_split <- 
  initial_split(rf_dat, 
                prop = 4/5)

rf_train <- 
  training(rf_split)

rf_test <- 
  testing(rf_split)

### Recipe
rf_recipe <- 
  recipe(effect_size ~ ., 
         data = rf_train) |> 
  step_impute_mean(all_numeric_predictors()) |> 
  step_dummy(all_nominal_predictors())

### Model specification and tuning
tune_spec <- 
  rand_forest(
    trees = tune(),
    mtry = tune(),
    min_n = tune()) |> 
  set_mode("regression") |> 
  set_engine("ranger", 
             importance = "permutation")

tune_workflow <- 
  workflow() |> 
  add_recipe(rf_recipe) |> 
  add_model(tune_spec)

### Cross-validation and grid setup
set.seed(234)
rf_fold <- vfold_cv(rf_train, 
                    v = 10)

set.seed(345)
rf_grid <- 
  grid_random(
    trees(range = c(100, 2500)),  
    mtry(range = c(1, 4)), 
    min_n(range = c(10, 30)),  
    size = 20  # Reduce number of grid points for efficiency
  )

# Tuning the model
regular_res <- 
  tune_grid(
    tune_workflow, 
    resamples = rf_fold, 
    grid = rf_grid,
    control = control_grid(save_pred = TRUE)
  )

## Finalize and fit the model
best_rmse <- select_best(regular_res, 
                         metric = "rmse")

final_workflow <- finalize_workflow(tune_workflow, 
                                    best_rmse)

## Evaluate on the test set
final_res <- last_fit(final_workflow, 
                      rf_split)

## Predictions and variable importance
trained <- 
  collect_predictions(final_res) |> 
  select(-.row, -.config)

final_model_mpa <-
  extract_fit_parsnip(final_res)

# Stop timer
toc()

# Reset plan to sequential
plan(sequential)

save(final_model_mpa, 
     file = "data/processed/final_mpa_rf.rda")


