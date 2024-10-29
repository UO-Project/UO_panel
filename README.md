# UO_panel
Panel dataset with polygon data and attribute tables for the areas designated by the Swedish police as vulnerable. Areas are reclassified, added, and removed on a biannual basis. First list is from 2015 and the most recent is from 2023. 

** (Very brief) documentation  **
- create_UO_panel.R has the code used to create the panel,which is stored in data/UO_panel.gpkg
- data/UO_key.xlsx has information gathered from openly available sources, mainly the Swedish language wikipedia page about the police-designated areas. It is also the source of area classification, removal and re-introduction for the years before 2021
- data/UO2021.shp, data/uso_2023.shp and associated ESRI files are the last two iterations of the list released by the police.
- data/USO_historiska.shp and associated ESRI files are the shapes for the areas no longer present in the list and not available via the 2021 and 2023 iterations.
- All areas other than the ones in USO_historiska were present in data/UO2021 and data/uso_2023, having gone in and out or being reclassified in the years between 2015 and 2021.These classifications and re-classifications were reconstructed using the lists available on Wikipedia, and recorded on UO_key.xlsx
- Shapes are assumed to remain constant for the years before 2021. This cannot be verified with available data.
- One area changed shape between 2021 and 2023 and the shape used in the panel is a combination of both. The change was very small and invisible to the eye. See create_UO_panel.R for details