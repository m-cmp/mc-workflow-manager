import os
from urllib.parse import quote

import duckdb
import requests


BROKER_URL = os.environ.get("OBJECT_STORAGE_BROKER_URL", "http://127.0.0.1:8889").rstrip("/")
BROKER_TOKEN = os.environ["OBJECT_STORAGE_BROKER_TOKEN"]


def broker_headers():
    return {"Authorization": "Bearer " + BROKER_TOKEN}


def sql_quote(value):
    text = str(value)
    return chr(39) + text.replace(chr(39), chr(39) * 2) + chr(39)


def sql_identifier(value):
    text = str(value)
    return chr(34) + text.replace(chr(34), chr(34) * 2) + chr(34)


def create_connection():
    connection = duckdb.connect()
    connection.execute("INSTALL httpfs")
    connection.execute("LOAD httpfs")
    connection.execute(
        "CREATE SECRET object_storage_broker (TYPE http, SCOPE "
        + sql_quote(BROKER_URL)
        + ", BEARER_TOKEN ?)",
        [BROKER_TOKEN],
    )
    return connection


def list_objects():
    response = requests.get(BROKER_URL + "/objects", headers=broker_headers(), timeout=30)
    response.raise_for_status()
    return response.json().get("objects", [])


def object_url(key):
    return BROKER_URL + "/object/" + quote(key, safe="")


def upload_file(key, local_path):
    size = os.path.getsize(local_path)
    headers = broker_headers()
    headers["Content-Length"] = str(size)
    with open(local_path, "rb") as source:
        response = requests.put(
            BROKER_URL + "/result/" + quote(key, safe=""),
            headers=headers,
            data=source,
            timeout=(10, 3600),
        )
    response.raise_for_status()
    return response.json()
