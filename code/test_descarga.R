
download_url <- "https://www.ine.cl/docs/default-source/ocupacion-y-desocupacion/bbdd/2022/csv/ene-2022-07-jja.csv?sfvrsn=9422c02c_4&download=true"
api_folder <- "/home/klaus/importine/data/" 
file_name_underscore <- "123.csv"
options(timeout=100)

download.file(download_url,  paste0(api_folder, file_name_underscore ))
