#!/bin/bash

set -eu

WORLD_DIR="$(pwd)/world"

mkdir -p $WORLD_DIR

# Download
echo "Downloading from $WORLD_URL..."
wget -q $WORLD_URL

# Unzip actual files to world directory
echo "Unzipping..."
unzip -q ./*.zip -d $WORLD_DIR
mv $WORLD_DIR/**/* $WORLD_DIR/
rm -rf ./*.zip
