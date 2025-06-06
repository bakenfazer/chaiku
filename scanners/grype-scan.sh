#!/bin/bash

set -euo pipefail

# === CONFIGURATION ===
TARGET_IMAGES=("chaiku-nginx-cg" "chaiku-frontend-cg" "chaiku-backend-cg" "cgr.dev/chainguard/postgres")

# Output files
CHAINGUARD_IMAGES="./scanners/scan-results/grype-chainguard-images.csv"
OTHER_IMAGES="./scanners/scan-results/grype-legacy-images.csv"
HEADER="Image,Package,Version,Vulnerability,Severity,Type,FixedInVersion"

# Track processed images
SEEN_IMAGES=""

# In-memory result buffers
chainguard_results=""
other_results=""
# =====================

# Get running containers
container_ids=$(docker compose ps -q)

if [ -z "$container_ids" ]; then
  echo "No running containers found via docker compose."
  exit 0
fi

echo "Scanning containers..."

for container_id in $container_ids; do
  image=$(docker inspect --format='{{.Config.Image}}' "$container_id")

  # Skip duplicates
  if echo "$SEEN_IMAGES" | grep -q "^$image$"; then
    echo "Skipping already scanned image: $image"
    continue
  fi

  echo "Scanning image: $image"

  # Check if image matches any in the TARGET_IMAGES list
  match="false"
  for pattern in "${TARGET_IMAGES[@]}"; do
    if [[ "$image" == "$pattern"* ]]; then
      match="true"
      break
    fi
  done

  # Run grype and capture results
  results=$(grype "$image" -o json | jq -r --arg image "$image" '
    .matches[] | [
      $image,
      .artifact.name,
      .artifact.version,
      .vulnerability.id,
      .vulnerability.severity,
      .artifact.type,
      (.vulnerability.fixedInVersion // "N/A")
    ] | @csv')

  if [[ -n "$results" ]]; then
    if [[ "$match" == "true" ]]; then
      chainguard_results+="$results"$'\n'
    else
      other_results+="$results"$'\n'
    fi
  fi

  SEEN_IMAGES="${SEEN_IMAGES}"$'\n'"$image"
done

# Write results if present
if [[ -n "$chainguard_results" ]]; then
  echo "$HEADER" > "$CHAINGUARD_IMAGES"
  echo "$chainguard_results" >> "$CHAINGUARD_IMAGES"
  echo "✔ Matched images saved to: $CHAINGUARD_IMAGES"
fi

if [[ -n "$other_results" ]]; then
  echo "$HEADER" > "$OTHER_IMAGES"
  echo "$other_results" >> "$OTHER_IMAGES"
  echo "✔ Other images saved to: $OTHER_IMAGES"
fi

if [[ -z "$chainguard_results" && -z "$other_results" ]]; then
  echo "✅ No vulnerabilities found in running images."
elif [[ -z "$chainguard_results" && "$match" == "true" ]]; then
  echo "✅ 🐙 No vulnerabilities found in Chainguard images! 🐙 ✅"
fi

