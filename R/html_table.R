library(dplyr)
library(DT)
library(htmlwidgets)
library(readr)

table_variables <- read_csv("data/table_variables.csv")

html_table <- table_variables %>% 
  mutate(
    url = paste0("<a href=\"http://sirene.fr", url, "\">", url, "</a>")
  ) %>% 
  datatable(., 
            filter = 'top',
            rownames = FALSE, 
            escape = FALSE)

html_table
saveWidget(html_table, 'index.html')
