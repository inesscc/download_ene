
import pandas as pd
import os
import re

# Convert all csv files to feather
for encuesta in os.listdir("data/"):
    for file in os.listdir("data/" + encuesta):
        if file.find("csv") != -1:
            directory = "data/" + encuesta + "/" + file
            data = pd.read_csv(directory, sep = None, engine='python', encoding ='latin1')
            directory_feather = directory.replace("csv", "feather")
            data.reset_index().to_feather(directory_feather)
            print(directory_feather )
            
            
# Remove all csv files
for encuesta in os.listdir("data/"):
    for file in os.listdir("data/" + encuesta):
        if file.find("csv") != -1:
            directory = "data/" + encuesta + "/" + file
            os.remove(directory)
            
# Rename ene files
for encuesta in os.listdir("data/"):
    for file in os.listdir("data/" + encuesta):
        if file.find("ene-") != -1:
            new_name = re.sub("ene-", "ene_", file)
            new_file = "data/" + encuesta + "/" + new_name 
            old_file= "data/" + encuesta + "/" + file
            os.rename(old_file, new_file)

# rename esi files
for encuesta in os.listdir("data/"):
    for file in os.listdir("data/" + encuesta):
        if file.find("esi-") != -1:
            new_name = re.sub("esi-", "esi_", file)
            new_name = re.sub("---", "-", new_name )
            new_file = "data/" + encuesta + "/" + new_name 
            old_file= "data/" + encuesta + "/" + file
            os.rename(old_file, new_file)
