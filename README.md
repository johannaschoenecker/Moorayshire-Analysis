Code for analysis and figures used to create "Widespread peat carbon losses driven by the 2025 Scottish megafire".

The 'Scripts' folder contains the code.
There are four parts to it:
a) A javascript Google Earth Engine script ("GEE_burn_severity_Sentinel2.js") to calculate and download the burn severity composite image (dNBR and RdNBR), which is then used for further analysis.
b) Processing of the field-measured peat burn depts
c) Climate analyses using SMAP and ERA5, using the scripts "SMAP_UK_SM.m", "Read_Analyze_ERA5_monthly_1940_now.m", "Process_Met_Office_data.m", "Process_Fire_Weather_Index.m", "final_climate_plots.m"
d) Emissions calculations and visualisations using the scripts "burn_severity.R", "landcover_map.R", "Summarizing land cover and burn severity at 10m intervals_1.R", "emissions_calculations.R" and "Plots and Maps.qmd"

