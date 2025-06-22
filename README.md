#Data &amp; code for: A ten-fold gap in effective global marine protection 

--- 

Total reef fish biomass and associated socioeconomic, anthropogenic and environmental variables, and derived global MPA data for reproducing the analysis in the manuscript "A ten-fold gap in effective global marine protection." 

A comprehensive description of the data included in this analysis can be found in the corresponding manuscript. Code for processing and reproducing the analysis in the corresponding manuscript are described under Code/Software below. 

---

# Description of the data and file structure 

GENERAL INFORMATION 
1. Title of Dataset: 
2. Author Information: Clausius, Ella 
3. Date of data collection:
4. Geographic location of data collection: Global

DATA & FILE OVERVIEW 

Description of dataset: 

File List: 
File 1 Name: rls_biomass_grf_data.Rdata
File 1 Description: Total reef fish biomass and socioeconimc, anthropogenic pressure, and broadscale environmental data for 2,382 opnely fished shallow Reef Life Survey (RLS) sites. 

File 2 Name: rls_mpa_data.Rdata 
File 2 Description: Site-level total reef fish biomass, and MPA age, level of protection against fishing, compliance with restrictions, and MPA size for 2,155 shallow RLS sites located inside a marine protected area (MPA). 

File 3 Name: MPA_zones.Rdata 
File 3 Description: Zone-level information on the global shallow reef-encompassing MPA network, derived from the ProtectedSeas (https://protectedseas.net/) database. 


METHODOLOGICAL INFORMATION 

In summary: 

---
Fish Biomass: collected via underwater visual census using a 50m transect. Detailed methods are available on the Reef Life Survey methods page: https://reeflifesurvey.com/methods/ and described in *Reef Life Survey: Establishing the Ecological Basis for Conservation of Shallow Marine Life* (Edgar et al., 2020, Biological Conservation).

Environmental Variables: broad-scale, remotely sensed environmental covariates were obtained from Bio-Oracle (https://www.bio-oracle.org/index.php), representing surface mean values at each site (2000–2020), extracted from rasters with a native resolution of 5-arcmins.

Human Gravity: calculated using the gravity of human impact model described in *Gravity of Human Impacts Mediates Coral Reef Conservation Gains* (Cinner et al., 2018, PNAS).

Gross Domestic Product (GDP) per capita: 

Human  Development Index (HDI): 

MPA size, age, level of fishing protection: 

Compliance: 


--- 

DATA-SPECIFIC INFORMATION FOR: rls_biomass_grf_data.Rdata 
1. Number of variables: 19 
2. Number of cases/rows: 2,382
3. Variable list:
   -rls_site_code: unique Reef Life Survey shallow reef site identifier
   -latitude: latitude in decimal degrees of reef site
   -longitude: longitude in decimal degrees of reef site 
   -depth: mean depth in meters of survey transect
   -sst_mean: Mean sea surface temperature (SST) at the site over the two years preceding the date of survey
   si_mean: silicate (mmol / m3)
   par_mean_mean: photosynthetically available radiation (Em2/day).
   chl_mean:  chlorophyll-a (mmol / m3)
   no3_mean: nitrate (mmol / m3)
   po4_mean: phosphate (mmol / m3)
   kdpar_mean_mean: diffuse attenuation at the surface in meters.
   dfe_mean: iron (mmol / m3)
   phyc_mean: phytoplankton (mmol / m3)
   depth_100km_mean: mean water depth within a 100km radius of reef site 
   depth_100km_range: water depth range within a 100km radius of reef site 
   total_gravity: a measure of how large and far away a human population is to a given reef site, as detailed in Cinner et al., 2018.
   gdp_per_capita: latest available gross domestic product (GFP) per capita of governing country that reef site falls within
   hdi: latest available human development index (HDI) score for governing country that reef site falls within. 
   total_biomass_log: total reef fish biomass recorded using Underwater Visual Census methods at a given Reef Life Survey site on the last available survey (log10 transformed).

DATA SPECIFIC INFORMATION FOR: rls_mpa_data.Rdata 
1. Number of variables: 7
2. Number of cases/rows:2,155
3. Variable list:
   rls_site_code: unique Reef Life Survey shallow reef site identifier
   survey_date: date of survey (dd/m/yyyy)
   level_fishing_protection: level of protection against fishing, 
   zone_marine_area_km:
   mpa_age:
   compliance:
   total_biomass_log: total reef fish biomass recorded using Underwater Visual Census methods at a given Reef Life Survey site on the last available survey (log10 transformed).

DATA SPECIFIC INFORMATION FOR: MPA_zones.Rdata 
1. Number of variables: 7
2. Number of cases/rows: 31,157
3. Variable list:
   zone_id:
   level_fishing_protection:
   network_id:
   zone_marine_area_km:
   longitude:
   latitude:
   mpa_age:

# Code & software 
Six R script files are provided to reproduce the analysis in the corresponding manuscript. All provided R files are described below.

'00_packages_functions.R': 

'01_geographic_random_forest.R':

'02_mpa_random_forest.R': 

'03_global_mpa_effectiveness_predictions.R':

'04_Global_MPA_effect_size_density_plot2.R': 

'05_global_MPA_effectiveness_threshold_plot2.R': 


   

   


