#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = T)

extends <- methods::extends


library(tidyverse)
library(cytominer)
library(stringr)
library(readr)
library(reshape2)


print("script started")

top_dir <-'/home/ubuntu/bucket/projects/'
proj_dir <- '2018_11_20_GeneCpdFollowup'
batch.name <- '2018_11_20_Batch1'


output <- "/home/ubuntu/bucket/projects/2018_11_20_GeneCpdFollowup/workspace/backend/2018_11_20_Batch1/"


plate.list <- c("BR00100032", "BR00100037")


sql.path <- NULL
for (pl in seq_along(plate.list)) {
  sql.path[pl] <- as.vector(paste0("/home/ubuntu/bucket/projects/2018_11_20_GeneCpdFollowup/workspace/backend/", batch.name, "/", plate.list[pl], "/", plate.list[pl], ".sqlite"))
}

print("Step1")

# reading sqlite
read_sql<- function(sql.path) {
  db <- DBI::dbConnect(RSQLite::SQLite(), sql.path)
  RSQLite::initExtension(db)
  
  image <- RSQLite::dbReadTable(conn = db, "Image")
  cells <- RSQLite::dbReadTable(conn = db, "Cells")
  nuclei <- RSQLite::dbReadTable(conn = db, "Nuclei")
  cytoplasm <- RSQLite::dbReadTable(conn = db, "Cytoplasm")
  
  dt <- cells %>%
    left_join(cytoplasm, by = c("TableNumber", "ImageNumber", "ObjectNumber")) %>%
    left_join(nuclei, by = c("TableNumber", "ImageNumber", "ObjectNumber")) %>%
    left_join(image, by = c("TableNumber", "ImageNumber"))
  
  return(dt)
  
}

print("Step2")

for (i in 1:length(sql.path)) {
  
  #Extracting metadata
  
  # reading sqlite file
  sql_data <- as.data.frame(lapply(sql.path[i], read_sql))
  
  selected_wells <- c('P01','O07','L12','D19','P24','A13','A12','D14',
                      'I04','A19','B04','K14','O06','C15','C11','M07',
                      'G05','G09','G18','G22','H05','H09','H18','H22',
                      'I03','I07','I16','I20','J03','J07','J16','J20')
  
  print("Step4")
  
  sql_data <- sql_data %>% dplyr::filter(Metadata_Well %in% selected_wells)
  
  
  
  #dmso <- merge(sql_data, meta, by.x="Image_Metadata_Well", by.y="Metadata_Well", all.x = TRUE)
  
  
  print("Step5") 
  
  
  
  readr::write_csv(sql_data, paste0(output,plate.list[i], "/", plate.list[i], "_selected_wells", ".csv"))
  print("Successfully executed") 
}
