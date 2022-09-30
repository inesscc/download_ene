library(RSelenium)
library(stringr)


# start the Selenium server
rdriver <- rsDriver(browser = "chrome",
                    port = 2122L,
                    chromever  = "105.0.5195.19",
)
remDr <- rdriver[["client"]]


download_data_esi <- function(year) {
  # Entrar al micrositio de la ENE
  remDr$navigate("https://www.ine.cl/estadisticas/sociales/ingresos-y-gastos/encuesta-suplementaria-de-ingresos")
  Sys.sleep(2)
  
  # Clickear la sección de bases de datos
  remDr$findElements(using = "class name", value = "navPrincipalDescargas")[[7]]$clickElement()
  Sys.sleep(2)
  
  # Clickear la sección que contiene archivos csv
  remDr$findElement(using = "xpath", value = '//*[@id="Content_C007_Col01"]/div/div/div[4]/div/div/div[4]')$clickElement()
  
  # Buscar los nodos de cada año
  year_nodes = remDr$findElements(using = "class name", value = "categoriaDescarga")
  indices = !sapply(year_nodes, function(x) x$getElementText()) %in% c("CSV", "SPSS", "RData", "STATA", "Manual y guía de variables")
  year_folders <- year_nodes[indices]
  names(year_folders) <- unlist(sapply(year_folders, function(x) x$getElementText()))
    # Hacer click en un año
  year_folders[[year]]$clickElement()
  Sys.sleep(2)
  
  # Bucar los nodos que contiene los archivos csv en un año
  csv_files = remDr$findElements(using = "class name", value = "iconoDescarga-csv")
  Sys.sleep(2)

  # Descargar archivos
  map(csv_files, ~.x$clickElement())
  Sys.sleep(15)
  
  
}

# Hay 12 años disponibles
map(as.character(2010:2021), download_data_esi)
download_data_esi("2019")


# Closing server
remDr$closeServer()
remDr$close()


