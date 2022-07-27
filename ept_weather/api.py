from flask import Flask
from flask import request, jsonify
import urllib.parse
import pymongo

app = Flask(__name__)
app.config["DEBUG"] = True

db_col=None

def init_app() :

    atlas_username=urllib.parse.quote_plus("weather_api_user")
    atlas_pwd=urllib.parse.quote_plus("p@sser123")

    url="mongodb+srv://{0}:{1}@weather.mbcjy.mongodb.net/?retryWrites=true&w=majority".format(atlas_username,atlas_pwd)
    client=pymongo.MongoClient(url)
    print("connecting to atlas cloud db...")
    db=client["weather"]
    if db is not None:
        col=db["campus_ept"]
        print("connected.")
    
    return col

    



@app.route('/get_weather',methods=['GET'])
def get_ept_weather():
    query_parameters = request.args
    how = query_parameters.get('how',None)
    last_record=db_col.find_one(sort=[( '_id', pymongo.DESCENDING )])
    if how is not None :
        if how=="daily" :
            return jsonify({'temperature':last_record["temperature"],'humidity':last_record["humidity"],'date_collecte':last_record["time"]})
        else : 
            return "bad request",400
    else :
        return jsonify({'temperature':last_record["temperature"],'humidity':last_record["humidity"],'date_collecte':last_record["time"]})




if __name__ == '__main__':
    db_col=init_app()
    app.run(host='0.0.0.0', port=8080)