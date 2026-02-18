#!/bin/bash
set -e

# ----- Set These Variables ----- #
ORG="<your-chainguard-organization>"
REGION="<your-aws-region>"
ACCOUNT_ID="<your-aws-account-id>"
# -------------------------------- #

CGR_BASE="cgr.dev/${ORG}"
ECR_BASE="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Authenticate to ECR
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_BASE

# Authenticate to cgr.dev (not needed if chainctl auth configure-docker already configured)
# chainctl auth token | docker login cgr.dev --username "$CGR_USERNAME" --password-stdin

# Fetch all repo/tag data once into a temp file
chainctl images repos list --parent $ORG -o json > $TMPFILE

# Get list of repo names
REPOS=$(jq -r '.items[].name' $TMPFILE)

for REPO in $REPOS; do
  echo "==> Processing $REPO..."

  # Create ECR repo if it doesn't exist
  aws ecr describe-repositories --repository-names "$REPO" --region $REGION \
    2>/dev/null || aws ecr create-repository --repository-name "$REPO" --region $REGION

  # Get activeTags for this specific repo
  TAGS=$(jq -r --arg repo "$REPO" '.items[] | select(.name == $repo) | .activeTags[]' $TMPFILE)

  for TAG in $TAGS; do
    echo "  Syncing $REPO:$TAG..."
    docker pull $CGR_BASE/$REPO:$TAG
    docker tag $CGR_BASE/$REPO:$TAG $ECR_BASE/$REPO:$TAG
    docker push $ECR_BASE/$REPO:$TAG
    docker rmi $CGR_BASE/$REPO:$TAG $ECR_BASE/$REPO:$TAG
  done
done