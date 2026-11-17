#!/usr/bin/env bash
set -euo pipefail

token="$(az account get-access-token --scope "https://ai.azure.com/.default" --query accessToken --output tsv)"

# The Foundry User assignment has to propagate before the data-plane calls are accepted.
sleep 45

export FOUNDRY_TOKEN="$token"
python3 - "$PROJECT_OPENAI_ENDPOINT" "$DOC_DIR" <<'PY'
import json
import pathlib
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

base = sys.argv[1].rstrip("/")
doc_dir = pathlib.Path(sys.argv[2])
token = __import__("os").environ["FOUNDRY_TOKEN"]
store_name = "ceges-dokumentumok"


def api(method, path, body=None):
    data = None
    headers = {"Authorization": f"Bearer {token}"}
    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(base + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode()
        raise SystemExit(f"{method} {path} failed: {error.code} {detail}")


def list_all(path):
    items = []
    after = None
    while True:
        query = {"limit": "100"}
        if after:
            query["after"] = after
        page = api("GET", f"{path}?{urllib.parse.urlencode(query)}")
        batch = page.get("data") or []
        items.extend(batch)
        if not page.get("has_more"):
            return items
        if not batch:
            raise SystemExit(f"{path} reported more pages without items")
        after = batch[-1]["id"]


def upload_file(path):
    result = subprocess.run(
        [
            "curl",
            "--fail",
            "--silent",
            "--show-error",
            "--request",
            "POST",
            "--url",
            f"{base}/files",
            "--header",
            f"Authorization: Bearer {token}",
            "--form",
            "purpose=assistants",
            "--form",
            f"file=@{path}",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)["id"]


stores = list_all("/vector_stores")
store = next((item for item in stores if item.get("name") == store_name), None)

if store is None:
    file_ids = [item["id"] for item in list_all("/files") if item.get("purpose") == "assistants"]
    if not file_ids:
        file_ids = [upload_file(path) for path in sorted(doc_dir.iterdir()) if path.is_file()]
    if not file_ids:
        raise SystemExit(f"no files in {doc_dir}")
    store = api(
        "POST",
        "/vector_stores",
        {"name": store_name, "file_ids": file_ids},
    )

store_id = store["id"]
for _ in range(60):
    current = api("GET", f"/vector_stores/{store_id}")
    counts = current.get("file_counts") or {}
    status = current.get("status")
    if counts.get("failed") or counts.get("cancelled"):
        raise SystemExit(f"vector store {store_name} failed: {json.dumps(counts)}")
    if status == "completed" and not counts.get("in_progress"):
        print(f"{store_name} {store_id} completed")
        raise SystemExit(0)
    if status == "expired":
        raise SystemExit(f"vector store {store_name} expired")
    time.sleep(5)

raise SystemExit(f"vector store {store_name} was not ready in time")
PY
