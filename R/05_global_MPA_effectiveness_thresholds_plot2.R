# ==============================================================================
# Plot showing percentage of shallow reef MPA network expected to have a 
# doubling of fish biomass under each scenario
# Ella Clausius 
# March 2025
# ==============================================================================

source("R/00_packages_functions.R")

#source("R/03_global_mpa_effectiveness_predictions.R")
load("data/processed/global_mpa_effectiveness_scenarios.Rdata")

load("data/protected_seas_zones.Rdata")

# calculate total area of MPA network 
global_mpa_coverage <- 
  sum(protected_seas_zones$zone_marine_area_km)

# Define thresholds and their log10 values
threshold_labels <- 
  seq(1, 3, by = 0.1) # Thresholds from 1 to 3

thresholds <- 
  log10(threshold_labels) # Corresponding log10 values

# Process the data
threshold_dat <- 
  mpa_scenarios |> 
  #filter(scenario %in% c("Status Quo", "Fully Protected & Old")) |> 
  distinct() |> 
  group_by(scenario, compliance, network_id) |> #
  summarise(
    effect_size = mean(pred_effect_size, na.rm = TRUE),
    total_area = sum(zone_marine_area_km, na.rm = TRUE),
    .groups = "drop"
  ) |> 
  rowwise() |> 
  mutate(
    area_effective = list(map_dbl(thresholds, ~ ifelse(effect_size >= ., 
                                                       total_area, 0)))
  ) |> 
  ungroup() |> 
  mutate(threshold = list(threshold_labels)) |> 
  unnest(c(area_effective, threshold)) |> 
  group_by(scenario, compliance, threshold) |> 
  summarise(
    percent_total_area = 
      round(sum(area_effective, na.rm = TRUE) / global_mpa_coverage * 100, 2),
    .groups = "drop"
  ) |> 
  group_by(scenario, threshold) |> 
  mutate(scaled_percent = scales::rescale(percent_total_area))  


threshold_dat |> 
  mutate(threshold = as.factor(threshold)) |> 
  ggplot(aes(y = percent_total_area, 
             x = threshold)) +
  ggforce::geom_link2(aes(group = threshold,
                          color = scaled_percent),
                      size = 14,
                      n = 500,
                      lineend = "round",
                      show.legend = NA) +
  geom_text(aes(y = percent_total_area,
                x = threshold,
                label = paste(round(percent_total_area, 0), "%",
                              sep = "")),
            size = 3,
            colour = "white",
            fontface = "bold") +
  facet_wrap(~factor(scenario, 
                     levels = c("Status Quo", 
                                "Fully Protected", 
                                "Old", 
                                "Fully Protected & Old")), 
             ncol = 1) + 
  guides(colour = guide_legend(title = "Compliance")) + 
  xlab(element_blank()) + 
  ylab("Percent of global MPA network area") +
  ggtitle(element_blank()) + 
  scale_color_gradientn(colors = c("#D50A0A", "#013369")) +  
  theme(
    strip.text = element_text(size = rel(1.33),
                              face = "plain",
                              hjust = 0),
    legend.position = "none"
  )


ggsave(last_plot(), 
       width = 10, 
       height = 10, 
       dpi = 300,  
       file = "figures/fig2_thresholds.png")




