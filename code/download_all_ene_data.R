library(RSelenium)
library(stringr)


# start the Selenium server
rdriver <- rsDriver(browser = "chrome",
                    port = 2122L,
                    chromever  = "105.0.5195.19",
)
remDr <- rdriver[["client"]]


download_data_ene <- function(year) {
  # Entrar al micrositio de la ENE
  remDr$navigate("https://www.ine.cl/estadisticas/sociales/mercado-laboral/ocupacion-y-desocupacion")
  Sys.sleep(2)

  # Clickear la sección de bases de datos
  remDr$findElements(using = "class name", value = "navPrincipalDescargas")[[7]]$clickElement()
  Sys.sleep(2)

  # Buscar los nodos de cada año
  year_nodes = remDr$findElements(using = "class name", value = "categoriaDescarga")
  indices = !sapply(year_nodes, function(x) x$getElementText()) %in% c("Bases anualizadas", "Libro de Códigos")
  carpetas <- year_nodes[indices]

  # Hacer click en cada año
  carpetas[[year]]$clickElement()
  Sys.sleep(2)

  # Bucar el nodo que contiene los archivos csv
  csv <- remDr$findElement(using = "xpath", value = '//*[@id="Content_C007_Col01"]/div/div/div[4]/div/div[2]/div[1]')

  # Si no encuentra la sección adecuada en el primer nodo, se busca en el tercero
  if (csv$getElementText() != "Formato CSV") {
    csv <- remDr$findElement(using = "xpath", value = '//*[@id="Content_C007_Col01"]/div/div/div[4]/div/div[2]/div[3]')
  }
  csv$clickElement()
  Sys.sleep(2)

  # Encontrar los nodos que contienen los archivos para descargar
  files <- remDr$findElements(using = "class", value = "widArchNavArchivoDescarga")

  # Descargar archivos
  map(files, ~.x$clickElement())


}

# Hay 13 años disponibles
map(1:13, download_data_ene)



# Closing server
remDr$closeServer()
remDr$close()


