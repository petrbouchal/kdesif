library(arrow)
library(writexl)
library(purrr)
library(here)
library(stringr)
library(tidyr)
library(dplyr)

cnf <- config::get()
ds <- open_dataset(here::here("data-output", "dtl-all-arrow"))

ops_chunks <- ds %>% select(op_id, chunk) %>% collect() %>% distinct()

dir <- cnf$excel_output_dir
dir.create(dir, showWarnings = F, recursive = T)

save_one_excel <- function(ds, op, chnk, dir) {
  df_op_chunk <- ds %>%
    filter(chunk == chnk, op_id == op) %>%
    collect()
  chunk_padded <- str_pad(chnk, width = 2, pad = "0")
  filename <- file.path(dir, paste0(op, "_", chunk_padded, ".xlsx"))
  write_xlsx(df_op_chunk, filename)
}

walk2(ops_chunks$op_id, ops_chunks$chunk, ~save_one_excel(ds, .x, .y, dir))

