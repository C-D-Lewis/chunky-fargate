#!/bin/bash

set -eu

WORLD_DIR="$(pwd)/world"
BUCKET_DIR_NAME="chunky-fargate/worlds"

mkdir -p $WORLD_DIR

# Download world zip file from S3
aws s3 cp \
  "s3://$BUCKET/$BUCKET_DIR_NAME/$WORLD_NAME.zip" \
  "./$WORLD_NAME.zip"

# Unzip actual files to world directory
echo "Unzipping..."
unzip -q ./*.zip -d $WORLD_DIR
mv $WORLD_DIR/**/* $WORLD_DIR/

# Cleanup
rm -rf ./*.zip
