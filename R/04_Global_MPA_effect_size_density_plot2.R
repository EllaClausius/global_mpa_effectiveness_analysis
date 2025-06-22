
source("R/00_packages_functions.R")

#source("R/03_global_mpa_effectiveness_predictions.R")
load("data/processed/global_mpa_effectiveness_scenarios.Rdata")


density_dat <- 
  mpa_scenarios |> 
  group_by(network_id, 
           scenario, 
           compliance) |> 
  summarise(bio_diff = 10^(mean(pred_effect_size))) 





density_dat |> 
  pivot_wider(names_from = "compliance", 
              values_from = "bio_diff") |> 
  ggplot() + 
  geom_density(aes(y = High, x = ..density..), 
               trim = TRUE, 
               adjust = 1.5, 
               alpha = 0.75, 
               fill = "#013369", 
               colour = "#013369") + 
  geom_density(aes(y = Low, x = -..density..), 
               trim = TRUE, 
               alpha = 0.75, 
               adjust = 1.5, 
               fill = "#D50A0A", 
               colour = "#D50A0A") +
  geom_boxplot(aes(y = High, x = 0.2),
               colour = "#013369",  
               width = .2,
               linewidth = .5, 
               outliers = FALSE,
               show.legend = FALSE) +
  geom_boxplot(aes(y = Low, x = -.2),
               colour = "#D50A0A",  
               width = .2,
               linewidth = 0.5,
               outliers = FALSE,
               show.legend = FALSE) +
  scale_shape_manual(values = c(19, 1)) +
  coord_fixed(ratio = 1) +
  xlim(c(-2.5, 2.5)) + 
  geom_hline(yintercept = 1, 
             colour = "darkgrey", 
             linetype = "dashed") + 
  xlab("Density of MPAs") + 
  ylab("Biomass differnce") +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_blank(), 
    axis.text = element_text(face = "plain", 
                             color = "black", 
                             size = 10),
    axis.title = element_text(face = "plain", 
                              size = rel(1.33)),
    axis.title.x = element_text(margin = ggplot2::margin(0.5, 0, 0, 0, 
                                                         unit = "cm")),
    axis.title.y = element_text(margin = ggplot2::margin(0, 0.5, 0, 0, 
                                                         unit = "cm"), 
                                angle = 90),
    plot.title = element_text(face = "plain", 
                              size = rel(1.67), 
                              hjust = 0),
    axis.line.x = element_line(colour = "black"), 
    plot.title.position = "plot",
    plot.background = element_rect(fill = "#ffffff", 
                                   color = NA),
    panel.background = element_rect(fill = "#ffffff", 
                                    color = NA),
    panel.grid.major =  element_line(color = "#ffffff"),
    panel.border = element_blank(),
    strip.background = element_blank(),
    strip.text = element_text(size = rel(1.33), 
                              face = "plain", 
                              hjust = 0), 
    legend.position = "bottom", 
    legend.title.position = "left",
    legend.direction = "horizontal"
  )   + 
  facet_wrap(~factor(scenario, 
                     levels = c("Status Quo",
                                "Fully Protected", 
                                "Old", 
                                "Fully Protected & Old")), 
             ncol = 4)


ggsave(last_plot(),
       width = 10, 
       height = 10,  
       dpi = 300, 
       file = "fig1_density_all.png")

