#!/bin/bash

set -eu

# World location in this context
WORLD_DIR="$(pwd)/world"
# Worlds location in the bucket
BUCKET_DIR_NAME="chunky-fargate/worlds"

# Make local world directory
mkdir -p $WORLD_DIR

# Download world zip file from S3
aws s3 cp \
  "s3://$BUCKET/$BUCKET_DIR_NAME/$WORLD_NAME.zip" \
  "./$WORLD_NAME.zip"

# Unzip actual files to local world directory
echo ">>> Unzipping..."
unzip -q ./*.zip -d $WORLD_DIR
mv $WORLD_DIR/**/* $WORLD_DIR/

# Cleanup downloaded zip
rm -rf ./*.zip
