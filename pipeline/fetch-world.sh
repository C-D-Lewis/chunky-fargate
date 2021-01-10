#!/bin/bash

set -eu

URL=$1

mkdir -p ./world

# Download
echo "Downloading from $URL..."
wget -qq $URL

# Unzip actual files to /world
echo "Unzipping..."
unzip -q ./*.zip -d world
mv world/**/* world/
rm -rf ./*.zip
