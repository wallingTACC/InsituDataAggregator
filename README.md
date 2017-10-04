# InsituDataAggregator

R scripts for processing field data and generating summary reports for In-Situ water well level loggers.

# clean_insitu_transducer_data.R

Given a directory of readings from potentially many different wells,  attempts to create a single aggregated dataset for analysis.  Specifically, it is designed to work with data extracted using the WinSituPlus.exe utility.

# new_data_report.Rmd

Provides a summary of all data processed by the above.

# Workflow

1. Install all package/library dependencies from both the .R and .Rmd scripts.
2. In clean_insitu_transducer_data.R: Update _process_dir(input_dir_path = "./data/Data/", output_file="./data/data.csv")_ at the bottom to point to a directory containing only WinSituPlus.exe extracted log files.
3. In new_data_report.Rmd: Update _report_data = read_csv("./data/full_test.csv")_ to point at output_file from step 2 and in Rstudio, click the 'Knit' button.