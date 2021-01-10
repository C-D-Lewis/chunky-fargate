#!/bin/bash

set -eu

WORLD_DIR="$(pwd)/world"

URL=$1

mkdir -p $WORLD_DIR

# Download
echo "Downloading from $URL..."
wget -q $URL

# Unzip actual files to world directory
echo "Unzipping..."
unzip -q ./*.zip -d $WORLD_DIR
mv $WORLD_DIR/**/* $WORLD_DIR/
rm -rf ./*.zip
