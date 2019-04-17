import linecache
import sys

import flask
import os
import helpers
import builtins
from escape_helpers import sparql_escape
from rdflib.namespace import Namespace
import requests
from datetime import datetime as dt
import traceback

app = flask.Flask(__name__)
URL_API_PARLEMENT = os.environ['URL_API_PARLEMENT']


@app.route("/", methods=['GET'])
def home():
    return "API Vlaams Parlement service is up and running"


@app.route("/test/files", methods=['GET'])
def create_files_locally():  # TODO remove

    q = f"""
        PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
        PREFIX dbpedia: <http://dbpedia.org/ontology/>
        
        SELECT ?file, ?extension
        WHERE {{
          GRAPH <http://mu.semte.ch/application> {{
            ?docVersie a ext:DocumentVersie .
            ?docVersie ext:file ?file .
            ?file dbpedia:fileExtension ?extension .
          }}
        }}
    """
    response = helpers.query(q)
    files = list()
    try:
        for file in response['results']['bindings']:
            try:
                f_dict = dict()
                for key, obj in file.items():
                    f_dict[key] = obj['value']
                files.append(f_dict)
            except:
                print("File parse error")
    except:
        print("Couldn't get files")
    """
    for f in files:
        comp = f.split('/')
        fid = comp[len(comp)-1]
        temp = open(f"{folder}/{fid}.txt", "w")
        temp.write("test file")
        temp.close()
    """
    return flask.jsonify(files)


def get_dict_value(obj, key, default):
    if key in obj:
        return obj[key]
    else:
        return default


def get_file_content(fileurl):  # TODO implement code for fetching the file content
    return "content"
    #return "Pg1lbmRvYmoNeHJlZg0KMCA0NDUNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDExMDkzMyAwMDAwMCBuDQowMDAwMTExOTI1IDAwMDAwIG4NCjAwMDAxMTI4NzMgMDAwMDAgbg0KMDAwMDExMzAzNyAwMDAwMCBuDQowMDAwMTEzNDQ2IDAwMDAwIG4NCjAwMDAxMTM5MDEgMDAwMDAgbg0KMDAwMDExNDQ4OCAwMDAwMCBuDQowMDAwMTE1NDg1IDAwMDAwIG4NCjAwMDAxMTkxNTcgMDAwMDAgbg0KMDAwMDEyMDE1OCAwMDAwMCBuDQowMDAwMTI0MzcwIDAwMDAwIG4NCjAwMDAxMjUzNzIgMDAwMDAgbg0KMDAwMDEyODE5OSAwMDAwMCBuDQowMDAwMTI5MTg4IDAwMDAwIG4NCjAwMDAxMjk4NjIgMDAwMDAgbg0KMDAwMDEzMDgzOCAwMDAwMCBuDQowMDAwMTMxMjM0IDAwMDAwIG4NCjAwMDAxMzIxOTQgMDAwMDAgbg0KMDAwMDEzMjUwMCAwMDAwMCBuDQowMDAwMTMzNTgwIDAwMDAwIG4NCjAwMDAxMzYyMTYgMDAwMDAgbg0KMDAwMDE1MTQ4MCAwMDAwMCBuDQowMDAwMTUxNzI5IDAwMDAwIG4NCjAwMDAxNjEwODIgMDAwMDAgbg0KMDAwMDE2MTMzNiAwMDAwMCBuDQowMDAwMTc1NjIzIDAwMDAwIG4NCjAwMDAxNzU4NzcgMDAwMDAgbg0KMDAwMDE3NjE4NCAwMDAwMCBuDQowMDAwMTc3MTY0IDAwMDAwIG4NCjAwMDAxNzcyMDEgMDAwMDAgbg0KMDAwMDE4ODA0NCAwMDAwMCBuDQowMDAwMTg5MDA1IDAwMDAwIG4NCjAwMDAxODkzMjIgMDAwMDAgbg0KMDAwMDE5MDI5OSAwMDAwMCBuDQowMDAwMTkwODE1IDAwMDAwIG4NCjAwMDAxOTE3NzYgMDAwMDAgbg0KMDAwMDE5MjA5MyAwMDAwMCBuDQowMDAwMTkzMTg1IDAwMDAwIG4NCjAwMDAyNjg3NTIgMDAwMDAgbg0KMDAwMDI4NTgwMSAwMDAwMCBuDQowMDAwMjg2MDQ4IDAwMDAwIG4NCjAwMDAyOTYzNDQgMDAwMDAgbg0KMDAwMDI5NjU5NiAwMDAwMCBuDQowMDAwMzA1NTY5IDAwMDAwIG4NCjAwMDAzMDU4MjYgMDAwMDAgbg0KMDAwMDMwNjI0MSAwMDAwMCBuDQowMDAwMzA3MjI2IDAwMDAwIG4NCjAwMDAzMDcyNjMgMDAwMDAgbg0KMDAwMDMyMTg2NyAwMDAwMCBuDQowMDAwMzUwNTAyIDAwMDAwIG4NCjAwMDAzNTE0NjMgMDAwMDAgbg0KMDAwMDM1MTc4MCAwMDAwMCBuDQowMDAwMzUyNzU4IDAwMDAwIG4NCjAwMDAzNTMxNzQgMDAwMDAgbg0KMDAwMDM1NDEzNSAwMDAwMCBuDQowMDAwMzU0NDUyIDAwMDAwIG4NCjAwMDAzNTU1MTAgMDAwMDAgbg0KMDAwMDM1NjY2NyAwMDAwMCBuDQowMDAwMzU2OTc4IDAwMDAwIG4NCjAwMDAzNTc5NDYgMDAwMDAgbg0KMDAwMDM1Nzk4MyAwMDAwMCBuDQowMDAwMzc5MTI4IDAwMDAwIG4NCjAwMDAzODAxODAgMDAwMDAgbg0KMDAwMDM4MzQ4NiAwMDAwMCBuDQowMDAwMzgzNzk3IDAwMDAwIG4NCjAwMDAzODQ3NjUgMDAwMDAgbg0KMDAwMDM4NDgwMiAwMDAwMCBuDQowMDAwMzg1ODU0IDAwMDAwIG4NCjAwMDAzOTEwNzEgMDAwMDAgbg0KMDAwMDM5MTU5NiAwMDAwMCBuDQowMDAwNDA4MTg2IDAwMDAwIG4NCjAwMDA0MDg0NjcgMDAwMDAgbg0KMDAwMDQwOTQzNSAwMDAwMCBuDQowMDAwNDA5NDcyIDAwMDAwIG4NCjAwMDA0MTA1MjQgMDAwMDAgbg0KMDAwMDQxNTYwNCAwMDAwMCBuDQowMDAwNDE2MTEyIDAwMDAwIG4NCjAwMDA0MTcwODAgMDAwMDAgbg0KMDAwMDQxNzExNyAwMDAwMCBuDQowMDAwNDE4MTgyIDAwMDAwIG4NCjAwMDA0MjM5OTMgMDAwMDAgbg0KMDAwMDQyNDA2MiAwMDAwMCBuDQowMDAwNDI0MTU4IDAwMDAwIG4NCjAwMDA0MzcxNDIgMDAwMDAgbg0KMDAwMDQzNzQyOCAwMDAwMCBuDQowMDAwNDM3Njg3IDAwMDAwIG4NCjAwMDA0Mzc3MTIgMDAwMDAgbg0KMDAwMDQzODA3OSAwMDAwMCBuDQowMDAwNDM4NTcyIDAwMDAwIG4NCjAwMDA0Mzk1NDAgMDAwMDAgbg0KMDAwMDQzOTU3NyAwMDAwMCBuDQowMDAwNDQwNjI5IDAwMDAwIG4NCjAwMDA0NDQ0MzIgMDAwMDAgbg0KMDAwMDQ0NDkzNiAwMDAwMCBuDQowMDAwNDQ1OTA0IDAwMDAwIG4NCjAwMDA0NDU5NDEgMDAwMDAgbg0KMDAwMDQ0Njk5NCAwMDAwMCBuDQowMDAwNDQ5Njc3IDAwMDAwIG4NCjAwMDA0NTAxMTMgMDAwMDAgbg0KMDAwMDQ1MTA4MSAwMDAwMCBuDQowMDAwNDUxMTE5IDAwMDAwIG4NCjAwMDA0NTIwODIgMDAwMDAgbg0KMDAwMDQ1MjQwMSAwMDAwMCBuDQowMDAwNDUzMzc5IDAwMDAwIG4NCjAwMDA0NTM3NzIgMDAwMDAgbg0KMDAwMDQ1NDczMyAwMDAwMCBuDQowMDAwNDU1MDUyIDAwMDAwIG4NCjAwMDA0NTYwNDIgMDAwMDAgbg0KMDAwMDQ1NzMxOSAwMDAwMCBuDQowMDAwNDU4MjgyIDAwMDAwIG4NCjAwMDA0NTg2MDEgMDAwMDAgbg0KMDAwMDQ1OTU4MSAwMDAwMCBuDQowMDAwNDYwMDI5IDAwMDAwIG4NCjAwMDA0NjA5OTIgMDAwMDAgbg0KMDAwMDQ2MTMxMSAwMDAwMCBuDQowMDAwNDYyMzkyIDAwMDAwIG4NCjAwMDA0NjYzMTggMDAwMDAgbg0KMDAwMDQ2NjM0NSAwMDAwMCBuDQowMDAwNDY2NzY3IDAwMDAwIG4NCjAwMDA0NjY4MzcgMDAwMDAgbg0KMDAwMDQ2NjkxOCAwMDAwMCBuDQowMDAwNDczMzE4IDAwMDAwIG4NCjAwMDA0NzM1ODEgMDAwMDAgbg0KMDAwMDQ3Mzc0MiAwMDAwMCBuDQowMDAwNDczNzY5IDAwMDAwIG4NCjAwMDA0NzQwNjcgMDAwMDAgbg0KMDAwMDQ3NTA0NCAwMDAwMCBuDQowMDAwNDc1MDgzIDAwMDAwIG4NCjAwMDA0NzYxNTEgMDAwMDAgbg0KMDAwMDQ3OTQ2OCAwMDAwMCBuDQowMDAwNDc5NDk1IDAwMDAwIG4NCjAwMDA0Nzk4MDggMDAwMDAgbg0KMDAwMDQ4MDc4NSAwMDAwMCBuDQowMDAwNDgwODI0IDAwMDAwIG4NCjAwMDA0ODE5ODMgMDAwMDAgbg0KMDAwMDQ4MjgwOSAwMDAwMCBuDQowMDAwNDg0NTk5IDAwMDAwIG4NCjAwMDA0ODQ2MzggMDAwMDAgbg0KMDAwMDQ4NjA2MyAwMDAwMCBuDQowMDAwNDg2MzQ5IDAwMDAwIG4NCjAwMDA0ODY2NDIgMDAwMDAgbg0KMDAwMDQ5MDA4NCAwMDAwMCBuDQowMDAwNDk1ODUxIDAwMDAwIG4NCjAwMDA0OTY2MTggMDAwMDAgbg0KMDAwMDQ5NjkwMiAwMDAwMCBuDQowMDAwNDk3MzQ5IDAwMDAwIG4NCjAwMDA0OTc4MzYgMDAwMDAgbg0KMDAwMDQ5ODExNSAwMDAwMCBuDQowMDAwNDk4NDI5IDAwMDAwIG4NCjAwMDA0OTg3NzYgMDAwMDAgbg0KMDAwMDQ5OTIxNiAwMDAwMCBuDQowMDAwNDk5NTgxIDAwMDAwIG4NCjAwMDA0OTk5NDYgMDAwMDAgbg0KMDAwMDUwMDI5MyAwMDAwMCBuDQowMDAwNTAwNzMwIDAwMDAwIG4NCjAwMDA1MDEwNzcgMDAwMDAgbg0KMDAwMDUwMTUxNyAwMDAwMCBuDQowMDAwNTAxODgyIDAwMDAwIG4NCjAwMDA1MDIyMjkgMDAwMDAgbg0KMDAwMDUwMjY2NiAwMDAwMCBuDQowMDAwNTAzMDMxIDAwMDAwIG4NCjAwMDA1MDM0NTEgMDAwMDAgbg0KMDAwMDUwMzk0MiAwMDAwMCBuDQowMDAwNTA0MzkyIDAwMDAwIG4NCjAwMDA1MDQ1MDYgMDAwMDAgbg0KMDAwMDUwNDY3MCAwMDAwMCBuDQowMDAwNTA1MDQ1IDAwMDAwIG4NCjAwMDA1MDU0NTkgMDAwMDAgbg0KMDAwMDUwNTg5NSAwMDAwMCBuDQowMDAwNTA2NDEwIDAwMDAwIG4NCjAwMDA1MDY2MDcgMDAwMDAgbg0KMDAwMDUwNjg3NiAwMDAwMCBuDQowMDAwNTA3NjIxIDAwMDAwIG4NCjAwMDA1Mzk3NzYgMDAwMDAgbg0KMDAwMDU5MjM3NCAwMDAwMCBuDQowMDAwNTkyNjQ5IDAwMDAwIG4NCjAwMDA2MTkzMzcgMDAwMDAgbg0KMDAwMDYxOTUzNCAwMDAwMCBuDQowMDAwNjE5ODEyIDAwMDAwIG4NCjAwMDA2MjAyMTggMDAwMDAgbg0KMDAwMDYyMDkzNCAwMDAwMCBuDQowMDAwNjIxMTEyIDAwMDAwIG4NCjAwMDA2MjE4NDAgMDAwMDAgbg0KMDAwMDYyMjU3MiAwMDAwMCBuDQowMDAwNjIyNzE4IDAwMDAwIG4NCjAwMDA2MjM0NjIgMDAwMDAgbg0KMDAwMDYyNDIwNiAwMDAwMCBuDQowMDAwNjI0OTE1IDAwMDAwIG4NCjAwMDA2MjUxNzYgMDAwMDAgbg0KMDAwMDYyNTQyNSAwMDAwMCBuDQowMDAwNjI1NDk1IDAwMDAwIG4NCjAwMDA2NTQxODEgMDAwMDAgbg0KMDAwMDY1NDQ3OSAwMDAwMCBuDQowMDAwNjU0OTAxIDAwMDAwIG4NCjAwMDA2NTUwMzMgMDAwMDAgbg0KMDAwMDY2OTM5NiAwMDAwMCBuDQowMDAwNjY5NDkzIDAwMDAwIG4NCjAwMDA2Njk3NDggMDAwMDAgbg0KMDAwMDY2OTg3OCAwMDAwMCBuDQowMDAwNzA5Njg1IDAwMDAwIG4NCjAwMDA3MDk4MTUgMDAwMDAgbg0KMDAwMDcwOTg1OSAwMDAwMCBuDQowMDAwNzEyNDI1IDAwMDAwIG4NCjAwMDA3MTM4NTEgMDAwMDAgbg0KMDAwMDcxNDQyNSAwMDAwMCBuDQowMDAwNzE0NTIxIDAwMDAwIG4NCjAwMDA3MTQ2MTYgMDAwMDAgbg0KMDAwMDcxNDcxMyAwMDAwMCBuDQowMDAwNzE0ODEwIDAwMDAwIG4NCjAwMDA3MTQ5MDcgMDAwMDAgbg0KMDAwMDcxNTAwNiAwMDAwMCBuDQowMDAwNzE1MTMyIDAwMDAwIG4NCjAwMDA3MTc3MTMgMDAwMDAgbg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KMDAwMDAwMDAwMCA2NTUzNSBmDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMDAgNjU1MzUgZg0KdHJhaWxlcg0KPDwvU2l6ZSA0NDUvSURbPDE0MDg4NTAwRTE3QTQ0NDdCNDA1REVFNzk2QkFBNUM0PjxCRDFBRERBMTc3M0U2MjRGOEY3QkE5RkNERjgyNDY4MT5dPj4NCnN0YXJ0eHJlZg0KMTE2DQolJUVPRg0K"


def PrintException():
    exc_type, exc_obj, tb = sys.exc_info()
    f = tb.tb_frame
    lineno = tb.tb_lineno
    filename = f.f_code.co_filename
    linecache.checkcache(filename)
    line = linecache.getline(filename, lineno, f.f_globals)
    print('EXCEPTION IN ({}, LINE {} "{}"): {}'.format(filename, lineno, line.strip(), exc_obj))


@app.route("/parlement/push/new", methods=['POST'])  # TODO cleanup code
def new_push():
    try:
        req = flask.request.json
        procedurestap = req['procedurestap']
        ps_comp = procedurestap.split('/')
        ps_id = ps_comp[len(ps_comp)-1]
        q = f"""
            PREFIX core: <http://mu.semte.ch/vocabularies/core/>
            PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
            PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
            PREFIX dct: <http://purl.org/dc/terms/>
            PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
            PREFIX adms: <http://www.w3.org/ns/adms#>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            PREFIX dbpedia: <http://dbpedia.org/ontology/>
            PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
            PREFIX nfo: <http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#>
            PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
            PREFIX prov: <http://www.w3.org/ns/prov#>
            
            SELECT *
            WHERE {{
              GRAPH <http://mu.semte.ch/application> {{
                ?subcase a dbpedia:UnitOfWork .
                ?subcase ext:bevatDocumentversie ?docVersie .
                ?docVersie ext:file ?file .
                ?docVersie dct:created ?filedate .
                ?file nfo:fileName ?filename .
                ?file dbpedia:fileExtension ?fileExtension .
                ?subcase dct:title ?scTitle .
                OPTIONAL {{
                  ?subcase dct:alternative ?scShortTitle .
                }}
                OPTIONAL {{
                  ?subcase dct:subject ?scTheme .
                  ?theme skos:prefLabel ?scThemeLabel .
                }}
                FILTER(?subcase = <{procedurestap}>)
              }}
            }}
        """
        res = helpers.query(q)
        parsed = list()
        try:
            for file in res['results']['bindings']:
                try:
                    f_dict = dict()
                    for key, obj in file.items():
                        f_dict[key] = obj['value']
                    parsed.append(f_dict)
                except:
                    print("File parse error")
        except:
            print("Couldn't parse files")

        parlement_obj = dict()
        parlement_obj['titel'] = get_dict_value(obj=parsed[0], key='scTitle', default="")
        parlement_obj['citeer-titel'] = get_dict_value(obj=parsed[0], key='scShortTitle', default="")
        parlement_obj['id'] = ps_id
        themes = set()
        files = list()
        for f in parsed:
            theme = get_dict_value(obj=f, key="scThemeLabel", default=None)
            if theme:
                themes.add(theme)
            f_obj = dict()
            f_obj['title'] = f['filename']  # TODO is there a title per document? If so, needs to be added to model OR removed from API obj
            f_obj['filename'] = f['filename']
            f_obj['content'] = get_file_content(fileurl=f['file'])
            f_obj['type'] = ""  # TODO how to get type? Mapping available?
            f_obj['date'] = get_dict_value(obj=f, key="filedate", default=str(dt.now()))
            files.append(f_obj)
        parlement_obj['themas'] = list(themes)
        parlement_obj['documenten'] = files

        req = requests.post(URL_API_PARLEMENT, data=parlement_obj)  # TODO test with actual endpoint
        if req.status_code == 200:
            return flask.jsonify({"message": "Push naar parlement was succesvol", "code": 200})
        else:
            return flask.jsonify({"message": "Push naar parlement is gefaald", "code": req.status_code})
    except Exception as e:
        PrintException()
        return flask.jsonify({"message": "Internal server error", "code": 500})


def get_files(phase):
    files = list()
    q = f"""
            PREFIX core: <http://mu.semte.ch/vocabularies/core/>
            PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
            PREFIX persoon: <http://data.vlaanderen.be/ns/persoon#>
            PREFIX dct: <http://purl.org/dc/terms/>
            PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
            PREFIX adms: <http://www.w3.org/ns/adms#>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            PREFIX dbpedia: <http://dbpedia.org/ontology/>
            PREFIX besluitvorming: <http://data.vlaanderen.be/ns/besluitvorming#>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
            PREFIX nfo: <http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#>

            SELECT *
            WHERE {{
                GRAPH <http://mu.semte.ch/application> {{
                    ?subcase a dbpedia:UnitOfWork .
                    ?subcase ext:subcaseProcedurestapFase ?phase .
                    ?subcase ext:bevatDocumentversie ?docVersie .
                    ?docVersie ext:file ?file .
                    ?phase ext:procedurestapFaseCode ?code .
                    ?code skos:prefLabel ?label .
                    FILTER(?phase = <{phase}>)
                }}
            }}
        """
    response = helpers.query(q)
    try:
        for file in response['results']['bindings']:
            f_dict = dict()
            for key, obj in file.items():
                f_dict[key] = obj['value']
            files.append(f_dict)
    except:
        print("Could not parse results")
    return files


@app.route("/parlement/push", methods=['POST'])
def push_to_parliament():
    req = flask.request.json
    procedurestapfase = req['procedurestapfase']

    return flask.jsonify(get_files(procedurestapfase))


"""
Vocabularies
"""
mu = Namespace('http://mu.semte.ch/vocabularies/')
mu_core = Namespace('http://mu.semte.ch/vocabularies/core/')
mu_ext = Namespace('http://mu.semte.ch/vocabularies/ext/')

graph = os.environ.get('MU_APPLICATION_GRAPH')
SERVICE_RESOURCE_BASE = 'http://mu.semte.ch/services/'

"""
Start Application
"""
if __name__ == '__main__':
    builtins.app = app
    builtins.helpers = helpers
    builtins.sparql_escape = sparql_escape
    app_file = os.environ.get('APP_ENTRYPOINT')
    try:
        exec("from ext.app.%s import *" % app_file)
    except Exception as e:
        helpers.log(str(e))
    debug = True if (os.environ.get('MODE') == "development") else False
    app.run(debug=debug, host='0.0.0.0')
