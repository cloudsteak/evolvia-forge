#!/usr/bin/env bash
# Permanently delete a soft-deleted lab user so a later lab with the same
# username cannot come back with the previous Microsoft Authenticator registration.
# Entra keeps a deleted user, including authentication methods, for 30 days.
# The UPN is rewritten, but mailNickname stays the original student username.
#
# Usage: purge-deleted-entra-user.sh <username> [--wait] [--dry-run]

set -euo pipefail

username="${1:-}"
wait_for_deletion=false
dry_run=false

if [[ -z "$username" || "$username" == --* ]]; then
  echo "Usage: $0 <username> [--wait] [--dry-run]" >&2
  exit 1
fi
shift

for arg in "$@"; do
  case "$arg" in
    --wait) wait_for_deletion=true ;;
    --dry-run) dry_run=true ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ ! "$username" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]]; then
  echo "Refusing unsafe username: $username" >&2
  exit 1
fi

export STUDENT_USERNAME="$username"
export PURGE_DRY_RUN="$dry_run"

purge_once() {
  python3 - << 'PY'
import json
import os
import subprocess
import urllib.parse

username = os.environ["STUDENT_USERNAME"]
dry_run = os.environ["PURGE_DRY_RUN"] == "true"
filter_expr = f"mailNickname eq '{username}'"
params = urllib.parse.urlencode(
    {
        "$count": "true",
        "$filter": filter_expr,
        "$select": "id,userPrincipalName,mailNickname",
        "$top": "50",
    },
    safe="$',",
)
url = "https://graph.microsoft.com/v1.0/directory/deletedItems/microsoft.graph.user?" + params

def az_rest(method, target):
    command = ["az", "rest", "--method", method, "--url", target]
    if method == "GET":
        command.extend(["--headers", "ConsistencyLevel=eventual", "-o", "json"])
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or f"az rest {method} failed").strip()
        raise SystemExit(detail)
    if method == "DELETE" or not result.stdout.strip():
        return {}
    return json.loads(result.stdout)

matches = []
page_url = url
while page_url:
    page = az_rest("GET", page_url)
    for user in page.get("value", []):
        if (user.get("mailNickname") or "").lower() == username.lower():
            matches.append(user)
    page_url = page.get("@odata.nextLink")

if not matches:
    print(f"No soft-deleted Entra user for {username}@evolvia.hu")
    raise SystemExit(0)

for user in matches:
    object_id = user["id"]
    principal = user.get("userPrincipalName") or object_id
    if dry_run:
        print(f"Would permanently delete soft-deleted user {principal} ({object_id})")
        continue
    print(f"Permanently deleting soft-deleted user {principal} ({object_id})")
    az_rest("DELETE", f"https://graph.microsoft.com/v1.0/directory/deletedItems/{object_id}")

print(f"purged={len(matches)}")
PY
}

if [[ "$wait_for_deletion" == false ]]; then
  purge_once
  exit 0
fi

# After Terraform deletes the user, Entra can take a little while to list it
# under deleted items. Keep trying so the Authenticator registration is removed.
for _ in $(seq 1 18); do
  output="$(purge_once)"
  printf '%s\n' "$output"
  if printf '%s\n' "$output" | grep -q '^purged='; then
    exit 0
  fi
  sleep 5
done

echo "No soft-deleted Entra user appeared for ${username}@evolvia.hu" >&2
exit 0
