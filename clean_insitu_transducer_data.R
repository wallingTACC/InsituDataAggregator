library(stringi)
library(lubridate)
library(parallel)
library(dplyr)



clean_file <- function(path='./data/Data/160929OC@CrkRd_2016-10-11_13-01-33-381.txt') {
  raw_data <- stri_read_lines(path)
  
  # Find consistent start point
  start_idx = grep(x = raw_data, pattern="^--------")[2] # Should be only 2
  
  
  # Extract site name
  site_line_idx = grep(x=raw_data, pattern="Site:")
  site_line = raw_data[site_line_idx]
  site_name = trimws(stri_split_fixed(site_line, ":", omit_empty=T, simplify=T)[1,2])
  
  # Extract time zone
  time_zone_idx = grep(x=raw_data, pattern="Time Zone:")
  if(length(time_zone_idx)==0) {
    time_zone = "Central Standard Time"
  } else {
    time_text = raw_data[time_zone_idx]
    time_zone = trimws(stri_split_fixed(time_text, ":", simplify=T)[1,2])
  }
  
  if(length(start_idx) != 1) {
    cat("More than 1 start idx found!!!")
  }
  
  # Must grab headers, column order could vary
  header_text = raw_data[start_idx - 1]
  header_vec = stri_split_regex(header_text, " {2,}", simplify = T, omit_empty=T)[1,] # Should always be single row, just grab that row
  
  # Data should always start here
  data_text = raw_data[start_idx + 1:length(raw_data)]
  
  # Get rid of bad/empty data
  data_text = data_text[!is.na(data_text)]
  data_text = data_text[data_text != ""]
  
  # Convert line into values
  data_mat = stri_split_regex(data_text, " {2,}", simplify = T, omit_empty=T)[]
  
  
  data = as.data.frame(data_mat)
  
  colnames(data) = header_vec
  
  # Further variable type cleansing
  cname = colnames(data)
  cname[cname %in% c("Date and Time", "Time Stamp", 'Time Stamp(GMT)')] <- "timestamp"
  colnames(data) = cname
  data$datetime = mdy_hms(data$timestamp, tz=time_zone)
  
  data$site = site_name
  
  # Get updated list of cnames
  cname = colnames(data)
  
  # Make 'Level-DTW (ft)' consistent
  if('Level-DTW (ft)' %in% cname) {
    cname[which(cname=='Level-DTW (ft)')] = 'Level Depth To Water (ft)'
    colnames(data) = cname
  }
  
  return(data)
}

process_dir <- function(input_dir_path="./data/full_test/", 
                        output_file="./data/full_test.csv") {
  files = list.files(path=input_dir_path, full.names=T)
  
  data_list = lapply(files, function(f) {
    cat(paste0("Cleaning file = ", f), fill=T)
    tryCatch({
    data_dfs = clean_file(f)
    }, error = function(e) {
       cat(paste0("Error procesing file: ", e), fill=T)
    }
    ) # End tryCatch
  }) # End lapply
  
  # Combine all data.frames into a single one
  result = bind_rows(data_list)
  
  write.csv(x = result, file=output_file, row.names=F)
}

# Main

process_dir(input_dir_path = "./data/Data/", output_file="./data/data.csv")
