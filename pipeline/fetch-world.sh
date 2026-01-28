#!/bin/bash

set -eu

# Worlds location in the bucket
BUCKET_DIR_NAME="chunky-fargate/worlds"

# Download world zip file from S3
aws s3 cp \
  "s3://$BUCKET/$BUCKET_DIR_NAME/$WORLD_NAME.zip" \
  "./$WORLD_NAME.zip"

# Unzip actual files to local world directory
echo ">>> Unzipping..."
unzip -q "./$WORLD_NAME.zip" -d ./temp
rm -rf ./world

mv ./temp/world .

# Cleanup downloaded zip
rm -rf ./*.zip ./temp
