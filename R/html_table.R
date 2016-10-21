library(dplyr)
library(DT)
library(htmlwidgets)
library(readr)
library(stringr)

html_table <- read_csv(
  file = "data/table_variables.csv"
  ) %>% 
  mutate_at(
    .cols = vars(contains("dessin"), type), 
    .funs = as.factor
    ) %>% 
  mutate(
    url = paste0("<a href=\"http://sirene.fr", url, "\">", url, "</a>")
  ) %>% 
  datatable(., 
            filter = 'top',
            rownames = FALSE, 
            escape = FALSE, 
            style = 'bootstrap')

html_table
saveWidget(html_table, 'index.html')
