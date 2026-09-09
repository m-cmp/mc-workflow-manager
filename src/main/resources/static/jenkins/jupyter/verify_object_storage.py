import os
import requests

from object_storage_access import broker_headers, list_objects, object_url


def verify():
    objects = list_objects()
    print("Object Storage broker list verified. provider=%s, storageId=%s, objects=%d" % (
        os.environ.get("OBJECT_STORAGE_PROVIDER", ""),
        os.environ.get("OBJECT_STORAGE_ID", ""),
        len(objects),
    ))
    if not objects:
        print("The bucket is empty. Upload data and rerun the notebook cells.")
        return

    for item in objects[:10]:
        print("  -", item.get("key", ""))
    if len(objects) > 10:
        print("  ... and %d more" % (len(objects) - 10))

    files = [
        item for item in objects
        if str(item.get("key", "")) and not str(item.get("key", "")).endswith("/")
    ]
    if not files:
        print("The bucket contains no readable files. Upload data and rerun the notebook cells.")
        return

    first_key = str(files[0]["key"])
    headers = broker_headers()
    headers["Range"] = "bytes=0-0"
    response = requests.get(object_url(first_key), headers=headers, stream=True, timeout=30)
    try:
        if response.status_code not in (200, 206):
            raise RuntimeError(
                "Object Storage object read failed. key=%s, status=%d, response=%s"
                % (first_key, response.status_code, response.text[:500])
            )
        print(
            "Object Storage object read verified. key=%s, status=%d, contentRange=%s"
            % (first_key, response.status_code, response.headers.get("Content-Range", ""))
        )
    finally:
        response.close()


if __name__ == "__main__":
    verify()
