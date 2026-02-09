#I wrote this script to help convert MetaPhlAn output into a format that MicrobiomeAnlyst can read

library(tidyverse)

files <- list.files(pattern = "_metaphlan_profile.txt$")

read_metaphlan <- function(file) {
  sample_id <- sub("_metaphlan_profile.txt", "", file)
  
  read_tsv(
    file,
    comment = "#",
    col_names = c("clade_name", "NCBI_tax_id",
                  "relative_abundance", "additional_species")
  ) %>%
    filter(str_detect(clade_name, "\\|s__")) %>%   # species level
    select(clade_name, relative_abundance) %>%
    rename(!!sample_id := relative_abundance)
}

abundance_table <- reduce(
  lapply(files, read_metaphlan),
  full_join,
  by = "clade_name"
)

abundance_table[is.na(abundance_table)] <- 0

colnames(abundance_table)[1] <- "#NAME"

write_tsv(
  abundance_table,
  "MicrobiomeAnalyst_abundance_table.txt"
)

metadata <- tibble(
  X.NAME = c("Sample0_control_gerbil", "Sample14_control_gerbil", "Sample90_control_gerbil", "Sample120_control_gerbil", "Sample2120_experimental_gerbil", "Sample30_experimental_gerbil", "Sample314_experimental_gerbil", "Sample390_experimental_gerbil"),  
             Group  = c("Control", "Control", "Control", "Control",
             "Experimental", "Experimental", "Experimental", "Experimental")
)

write_tsv(
  metadata,
  "MicrobiomeAnalyst_metadata.txt"
)
