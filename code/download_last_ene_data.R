library(RSelenium)
library(stringr)
options(timeout=180)

args = commandArgs(trailingOnly=TRUE)

# Start selenium server on DO machine
# Esto requirió hacer andar un servidor SELENIUM antes 
# sudo docker pull selenium/standalone-firefox:2.53.0
# sudo docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.0 

if (str_detect(system("cat /etc/os-release", intern = T)[[1]], "Debian") == TRUE | 
    str_detect(system("cat /etc/os-release", intern = T)[[6]], "20.04")) {
  remDr <- remoteDriver(
    remoteServerAddr = "172.17.0.3",
    port = 4444L,
    browserName = "firefox")
  
  remDr$open()
  
} else {
  # start the Selenium server on local machine
  
  eCaps <- list(chromeOptions = list(
    args = c('--headless', '--disable-gpu', "--remote-debugging-port=2122")
  ))
  
  
  rdriver <- rsDriver(browser = "chrome",
                      port = 2122L,
                      chromever  = "105.0.5195.52",
                      extraCapabilities = eCaps
                      
  )
  remDr <- rdriver[["client"]]
  
}








##################### 
# Download last_ene #
#####################

edit_file_name <- function(x, underscore = T) {
  edit_name <- tolower(x)
  edit_name <- str_extract(edit_name, "ene.+")
  
  if (underscore) {
    edit_name <- str_replace(edit_name, "ene ", "ene_")    
  }
  
  edit_name <- str_replace_all(edit_name, " ", "-")
  edit_name <- paste0(edit_name, ".csv")
  return(edit_name)
  
}



download_last_ene <- function(download_folder, api_folder, best_strategy = TRUE) {
  
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
  
  # Hacer click en el año más alto. El primer nodo corresponde al año más actual
  carpetas[[1]]$clickElement()
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
  
  # Elegir la url del último nodo, ya que este contiene la publicación más actual
  download_url <- files[[length(files)]]$getElementAttribute(attrName = "href")[[1]]
  Sys.sleep(2)
  
  # Crear el nombre del archivo, para darle la estructura que tienen los demás en las carpetas de la API
  file_name <- files[[length(files)]]$getElementText()[[1]]
  file_name_underscore <- edit_file_name(file_name)
  
  # Este es el nombre con el que se descarga el archivo  
  file_name_no_underscore <- edit_file_name(file_name, F)
  
  # Si el archivo ya existe en la carpeta de descargas, se elimina
  if (file.exists(paste0(download_folder, file_name_no_underscore))) {
    message("El archivo existía en la carpeta de descargas y fue eliminado")
    file.remove(paste0(download_folder, file_name_no_underscore))
  }
  
  # Si el archivo ya existe en la carpeta de la API, se elimina
  if (file.exists(paste0(api_folder, file_name_underscore))) {
    message("El archivo existía en la carpeta de la API y fue eliminado")
    file.remove(paste0(api_folder, file_name_underscore))
  }
  
  # La mejor opción para descar es lo que está dentro del if
  if (best_strategy) {
    # Descargar en la carpeta de la API. Esta es la copión preferida, pero la página tiene problemas y no siempre se hace la descarga
    download.file(download_url,  paste0(api_folder, file_name_underscore ))
    
  } else {
    
    # Click para descargar en la carpeta de descargas 
    files[[length(files)]]$clickElement()  
    
    
    # Esperar a que el archivo esté disponible en la carpeta de descargas. Cortar después de 3 minutos
    time1 <- Sys.time()
    total_time <- 0
    while (!file.exists(paste0(download_folder, file_name_no_underscore)) & total_time <= 180) {
      Sys.sleep(1)
      total_time <-  Sys.time() - time1   
      
    }
    
    # Copiar archivo desde la carpeta de descargas hasta la carpeta de la API
    file.copy(from = paste0(download_folder, file_name_no_underscore), to =  paste0(api_folder, file_name_underscore ) )
    
    # Eliminar el archivo de la carpeta de descargas
    if (file.exists(paste0(download_folder, file_name_no_underscore))) {
      file.remove(paste0(download_folder, file_name_no_underscore))
      message("El archivo descargado fue eliminado de la carpeta de descargas")
      
    }
    
    
  }
  
  
  # Comprobar que el archivo haya quedado guardado correctamente
  if (file.exists(paste0(api_folder, file_name_underscore))) {
    message("El archivo fue guardado exitosamente")
  } else {
    message("El archivo NO fue guardado")
  }
  
}

######################
# Ejecutar la función
######################
download_last_ene(args[[1]], args[[2]], best_strategy = args[[3]])

#"/home/klaus/Downloads/", "/home/klaus/ine/importine/data/ene/"
download_folder <- "/home/klaus/Downloads/"
api_folder <- "/home/klaus/ine/importine/data/ene/"

download_folder <- "/home/klaus/importine/"
api_folder <- "/home/klaus/importine/data/"

###############
# Cerrar server 
###############

if (Sys.info()[[3]] == "#142-Ubuntu SMP Fri Aug 26 12:12:57 UTC 2022") {
 
  
  
} else {
  # Closing server
  remDr$closeServer()
  remDr$close()
  rdriver[["server"]]$stop()
  rm(rdriver)
  gc()
  
}


