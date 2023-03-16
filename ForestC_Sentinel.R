#import libraries
library('rgdal')
library('sf')
library('raster')
library('sp')
library('stringr')

####
#Step 1---Clean the data
#read csv
setwd("/Users/emilyelizabeth/Python/Forest-carbon-estimation-main")
getwd()
tree_plots <- read.csv("ERM_Round1.csv")
#col names
head(tree_plots)
names(tree_plots)
#check lat/long look good
head(tree_plots$Longitude)
head(tree_plots$Latitude)
summary(tree_plots)
clean_tree_plots <- tree_plots[!is.na(tree_plots$Latitude),]
#verifying nulls dropped in both lat/long
summary(clean_tree_plots)
#shapefile of maine
maine_shp <- st_read("Data/Maine_State_Boundary_Line_Feature/Maine_State_Boundary_Line_Feature.shp")
#crs of maine shapefile = destination crs
dst_crs <- st_crs(maine_shp)
print(dst_crs)
#convert the dataframe to a spatial object using WGS84
plot_locations <- st_as_sf(clean_tree_plots, coords = c("Longitude", "Latitude"), crs = 4326)
plot(plot_locations,max.plot=19)
#Let's do a more interesting subset
tree_biomass<-clean_tree_plots[c('Latitude','Longitude','Live_Basal_Area')]
biomass_locations <- st_as_sf(tree_biomass, coords = c("Longitude", "Latitude"), crs = 4326)
plot(biomass_locations)
#apply plot buffer
plots_buff <- st_buffer(biomass_locations, 7.32)
plot(plots_buff)
#project in same crs as the maine shapefile to view
plots_buff <- st_transform(plots_buff, dst_crs)
#view both the tree plot buffers and maine
plot(st_geometry(plots_buff), col ='blue')
plot(st_geometry(maine_shp), add = T)
#write to a shapefile
st_write(plots_buff,"tree_plots_buffer.shp")

####
#Step 2---Working with the data
#load, view and project

#load the shapefile to use with the SP package
tree_plots_buff_shp <- st_read("tree_plots_buffer.shp")
maine_shp <- st_read("Data/Maine_State_Boundary_Line_Feature/Maine_State_Boundary_Line_Feature.shp")

#I don't think I need this right now
#loading the shapefile so that I can copy & manipulate it's dataframe
#I use this variable again later in a loop
#tree_plots_buff_shp2 <- readOGR("tree_plots_buffer.shp")
#make a df with all of the shp attributes
#tree_plots_df <- tree_plots_buff_shp2@data

#this view looks weird and cut off
plot(tree_plots_buff_shp$geometry)
plot(st_geometry(maine_shp), add = T)

#load & view one raster
#I changed this file name to 'raster2/T19TEL_20170902T153549_B8A_20m.jp2' when I ran it
band <- raster('raster2/T19TEL_20170902T153549_B8A_20m.jp2')

#R was slow to project the bands, so I opted to put the shapefile into 
#the bands crs for clipping
tree_plots_buff_shp <- st_transform(tree_plots_buff_shp, st_crs(band))

#view several together
plot(tree_plots_buff_shp$geometry)
plot(st_geometry(maine_shp), add = T)
plot(band, add = T)
#get a list of only bands 04
bands04 <- list.files('raster2', pattern="B04_20m.jp2", full.names = T)
#view these band 4s over maine to find the rasters w. the most
#data overlap to experiment with
for(i in 1:length(bands04)){
  r = raster(bands04[i])
  plot(r, add = T)
}

#view just the band
spplot(band)


####
#Step 3--extracting pixels

#list all of the bands
bands <- list.files('raster2', pattern=".jp2", full.names = T)
#isolate the band names from the file names
band.name <- str_sub(bands, 9, -5)
band.name
#extract pixels where the raster overlaps with each tree plot
#export to their own csv, name is the band name
for(i in 42:length(bands)){
  try({
    r <- raster(bands[i])
    new_name <- str_sub(bands[i], 9, -5)
    mean_ls <- extract(x = r, y = tree_plots_buff_shp, fun= mean, df= TRUE)
    write.csv(mean_ls, file = paste0(new_name,".csv"), row.names = TRUE)
  })
}

####
#Step 4--combine into training set    
  
library(dplyr)
library(readr)

#list all csvs
files <- list.files(path=wd, pattern='*.csv', full.names = FALSE)

#open all csvs and ignore the first column (empty data)
combined <- lapply(files,function(i){
  read.csv(i, header=TRUE, colClasses=c("NULL",NA,NA))
})

#combine the csvs
combined <- bind_rows(combined, id="ID")
summary(combined)

#write out to a csv to view and confirm
write.csv(combined, file = "training_set.csv", row.names = TRUE)