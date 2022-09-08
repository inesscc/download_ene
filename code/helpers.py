
import pandas as pd
import os

# Convert all csv files to feather
for encuesta in os.listdir("data/"):
    for file in os.listdir("data/" + encuesta):
        if file.find("csv") != -1:
            directory = "data/" + encuesta + "/" + file
            data = pd.read_csv(directory, sep = None, engine='python')
            directory_feather = directory.replace("csv", "feather")
            data.reset_index().to_feather(directory_feather)
            print(directory_feather )