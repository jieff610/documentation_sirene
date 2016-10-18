library(purrr)
library(rvest)
library(stringr)
library(tibble)
library(dplyr)
library(plyr)
library(tidyr)
library(readr)

get_item <- function(list, k) {
  list[[k]]
}

libelle <- "http://sirene.fr/sirene/public/static/liste-variables" %>%
  read_html() %>%
  html_nodes(css = "li a") %>%
  html_text()

url <- "http://sirene.fr/sirene/public/static/liste-variables" %>%
  read_html() %>%
  html_nodes(css = "li a") %>%
  html_attr("href")

table_variables <- tibble(libelle, url) %>%
  filter(str_detect(string = url, pattern = "/sirene/public/variable/")) %>% 
  mutate(
    libelle = str_sub(libelle, start = 8)
    )

table_variables %>% glimpse()

extract_number_of_tables <- function(url) {
  url %>%
    paste0("http://sirene.fr", .) %>%
    read_html() %>%
    html_nodes(css = "table.tabtexte") %>%
    html_attr("summary") %>%
    length() %>%
    tibble(number_of_tables = .)
}

# "/sirene/public/variable/siren" %>% extract_number_of_tables()

table_number_of_tables <- ldply(
  .data = table_variables$url,
  .fun = extract_number_of_tables,
  .progress = "text")

table_variables <- bind_cols(table_variables, table_number_of_tables)

extract_dessin_fichier <- function(url) {
  url %>%
    paste0("http://sirene.fr", .) %>%
    read_html() %>%
    html_nodes(css = "table.tabtexte") %>%
    get_item(k = 1) %>%
    html_table(header = TRUE) %>%
    as_tibble()
}
"/sirene/public/variable/siren" %>% extract_dessin_fichier()

table_dessin_fichier <- ldply(
  .data = table_variables$url,
  .fun = extract_dessin_fichier,
  .progress = "text")

table_variables <- bind_cols(table_variables, table_dessin_fichier)

extract_type_variable <- function(url) {
  url %>%
    paste0("http://sirene.fr", .) %>%
    read_html() %>%
    html_nodes(css = "table.tabtexte") %>% 
    keep(.p = (html_attr(x = ., name = "summary") == "Caractéristiques techniques")) %>% 
    get_item(k = 1) %>% 
    html_table(header = FALSE)  %>% 
    spread(key = X1, value = X2) %>% 
    as_tibble() 
  }
"/sirene/public/variable/siren" %>% extract_type_variable()

table_type_variable <- ldply(
  .data = table_variables$url,
  .fun = extract_type_variable,
  .progress = "text")

table_variables <- bind_cols(table_variables, table_type_variable)

table_variables %>% 
  glimpse()

table_variables <- table_variables %>% 
  select_(
    nom_abrege = ~ `Nom abrégé`, 
    ~ libelle, 
    type = ~ Type, 
    longueur = ~ Longueur, 
    dessin_M = ~ Moyen, 
    dessin_L = ~ Long, 
    dessin_XL = ~ `eXtra Long`, 
    ~ url
    )

write_csv(table_variables, path = "data/table_variables.csv")
