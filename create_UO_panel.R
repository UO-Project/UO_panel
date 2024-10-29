#NOTES:
#needs packages sf and readxl to run
#set working directory to the folder "UO_to_panel" or place the files 
#in the appropriate directory structure within your own R studio project
library(sf)
library(readxl)
#read shapes. Somehow the cops added a third coordinate that is 0 for all shapes
#hence st_zm() to remove it
UO2023<-st_read("data/uso_2023.shp")|>
  st_zm()
UO2021<-st_read("data/UO2021.shp")|>
  st_zm()
UOhist<-st_read("data/USO_historiska.shp")|>
  st_zm()

#read the harmonizing key from the excel spreadsheet
UOkey<-read_excel("data/UO_key.xlsx",sheet = "data")

#first pass at it using only names and shapes to build a harmonized panel. 
#area classification info for 2015, 2017 and 2019 from the wikipedia page in Swedish----
#first pick the shapes and add harmonized IDs and names 
shapes2021<-select(UO2021,area=namn)|>
  merge(select(UOkey,ID,area2021,area_panel),
        by.x="area",by.y="area2021")|>select(ID,area_panel)
shapes2023<-select(UO2023,area=NAMN)|>
  merge(select(UOkey,ID,area2023,area_panel),
        by.x="area",by.y="area2023")|>select(ID,area_panel)
shapeshist<-select(UOhist,area=namn)|>
  merge(select(UOkey,ID,areahist,area_panel),
        by.x="area",by.y="areahist")|>select(ID,area_panel)
#append and remove duplicates
shapes_all<-rbind(shapes2021,shapes2023,shapeshist)|>unique()
#Fisksättra has a shape that differs minimally between 2021 and 2023. 
#This difference is invisible to the naked eye, but keeps "unique()" from
#telling that it is the same row. I dissolve the two shapes by grouping 
#the whole bunch by ID and name (affects only Fisksättra b/c it is the only duplicate)
shapes_all<-group_by(shapes_all,ID,area_panel)|>
  summarize()
#create a long version of the UOkey IDs, names, and area types for each year
UO_panel<-select(UOkey,-c(area2021,area2023,areahist))|>
  pivot_longer(cols = c(`2015`,`2017`,`2019`,`2021`,`2023`),
               values_to = "type",names_to = "year")

# Merge with the shapes and drop years where area is not classified by the cops
UO_panel<-merge(UO_panel,shapes_all,by=c("ID","area_panel"))|>
  filter(!is.na(type))|>
  st_as_sf()|> # convert to sf
st_make_valid() # fix the invalid geometries that cops on too much caffeine create with their sharpies
#clean the strings
UO_panel<-mutate_at(UO_panel,.vars=vars(area_panel,type),.funs=str_squish,)
#year into integer
UO_panel<-mutate_at(UO_panel,.vars=vars(year),.funs=as.integer,)
#relabel R, U and S with long labels
UO_panel<-mutate(UO_panel,type=case_match(type,"R"~"Riskområde","S"~"Särskild utsatt område","U"~"Utsatt område"))

#save as gpkg
st_write(UO_panel,dsn="data/UO_panel.gpkg",append=F)
