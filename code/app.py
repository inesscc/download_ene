from flask import Flask
from flask import  request
import pandas as pd
from flask import jsonify
import os

app = Flask(__name__)

@app.route('/data', methods = ['GET'])
def download_data():
     name = request.args.get('encuesta')
     year = request.args.get('year')
     
     if name is None:
         text = 'por favor, ingresa una encuesta'
         return jsonify({"message": text})
     
     file = "data/{encuesta}/{encuesta}_{year}.csv".format(encuesta = name, year = year) #/home/klaus/ine/importine/
     data = pd.read_csv(file, sep = ";")
     data2 = data.iloc[0:30, 0:2 ]
     json_data = jsonify({"message": name + " dataset", "data": data2.to_dict()})
 
     return json_data
 
 
@app.route('/datasets', methods = ['GET'])
def get_dataset_list():
    files_dic = {name:os.listdir("data/" + name) for name in os.listdir("data/")}
    json_data = jsonify({ "datasets": files_dic})
    return json_data


@app.route('/')
def home():
    return jsonify({ "datasets": "blabla"}) 


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)
    #app.run()

