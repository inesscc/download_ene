
import requests
import pandas as pd
url = "http://localhost:8000/"

url  = "http://localhost:8000/data?dataset=epf_personas&year=vii"
r = requests.get(url = url)
r.status_code

data = r.json()
data 
df = pd.DataFrame.from_dict(data["data"] )
