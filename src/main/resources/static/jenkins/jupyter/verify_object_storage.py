import os
import requests

from object_storage_access import broker_headers, list_objects, object_url


def verify():
    objects = list_objects()
    print("Object Storage broker access verified. provider=%s, storageId=%s, objects=%d" % (
        os.environ.get("OBJECT_STORAGE_PROVIDER", ""),
        os.environ.get("OBJECT_STORAGE_ID", ""),
        len(objects),
    ))
    if objects:
        first_key = str(objects[0].get("key", ""))
        response = requests.head(object_url(first_key), headers=broker_headers(), timeout=30)
        response.raise_for_status()
        for item in objects[:10]:
            print("  -", item.get("key", ""))
        if len(objects) > 10:
            print("  ... and %d more" % (len(objects) - 10))
    else:
        print("The bucket is empty. Upload data and rerun the notebook cells.")


if __name__ == "__main__":
    verify()
