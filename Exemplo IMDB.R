library(tidyverse)
library(rvest)
library(polite)
library(dplyr)
library(magrittr)

# Definindo a URL inicial
prox_link <- "https://www.imdb.com/list/ls068082370/"

# Criando uma lista para armazenar os data frames de cada página
filmes_list <- list()

# Iterando pelas páginas de 1 a 3
for (pagina in 1:3) {
  # Lendo o conteúdo HTML da página atual
  html <- read_html(prox_link)
  
  # Extraindo o nome do filme
  nome <- html %>% html_nodes(".lister-item-header a") %>% html_text()
  
  # Extraindo o ano do filme
  ano <- html %>% html_nodes(".text-muted.unbold") %>% html_text()
  ano <- str_extract(ano[4:103], "\\d+") %>% as.integer()
  
  # Extraindo a classificação do filme
  nota <- html %>% 
    html_nodes(".ipl-rating-star.small .ipl-rating-star__rating") %>% 
    html_text() %>% as.numeric()
  
  # Extraindo o gênero do filme
  genero <- html %>% html_nodes(".genre") %>% html_text()
  genero <- str_remove_all(genero, "\\s+") # Removendo espaços em branco extras
  
  # Extraindo o diretor do filme
  diretor <- html %>% html_nodes(".text-muted a:nth-child(1)") %>% html_text()
  
  # Extraindo a duração do filme
  duracao <- html %>% html_nodes(".runtime") %>% html_text()
  duracao <- str_extract(duracao, "\\d+") %>% as.integer()
  
  # Extraindo o elenco do filme
  direlenco <- html %>% html_nodes(".text-small:nth-child(6)") %>% html_text()
  direlenco <- str_replace_all(direlenco, "\\n", " ") # Substituindo caracteres de nova linha
  
  # Criando um data frame para a página atual
  filmes_page <- data.frame(nome, ano, nota, genero, diretor, duracao)
  
  # Adicionando o data frame à lista
  filmes_list[[pagina]] <- filmes_page
  
  # Definindo a URL para a próxima página
  prox_link <- html %>%
    html_nodes("a.flat-button.lister-page-next.next-page") %>%
    html_attr("href") %>%
    url_absolute("https://www.imdb.com/list/ls068082370/")
  
  # Exibindo o número da página atual
  message(paste("Página", pagina))
}

# Gerando o data frame com todos os dados
filmes <- bind_rows(filmes_list)

# Removendo linhas com valores NA
filmes <- filmes[complete.cases(filmes), ]

