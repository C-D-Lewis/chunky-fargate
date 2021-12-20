#!/bin/bash

# Use Chunky 2.x ChunkyLauncher.jar
#
# Install dependencies:
#   sudo apt-get install default-jdk libopenjfx-java libcontrolsfx-java jq
#
# Usage:
#   ./pipeline/render-scene.sh $worldDir $sceneDir $targetSpp
#
# Example:
#   ./pipeline/render-scene.sh "/mnt/c/Users/Chris/Desktop/village-day-8" "/mnt/c/Users/Chris/.chunky/scenes/village-iso" "300"

set -eu

# Minecraft version
MC_VERSION="1.18.1"
# Local scenes directory
SCENES_DIR="./scenes"

# Path to world
WORLD_DIR=$1
# Path to scene JSON file directory
SCENE_DIR=$2
# Target samples
TARGET_SPP=$3

# First time setup of resources
if [[ ! -d "resources" ]]; then
  java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar --update
  java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar -download-mc $MC_VERSION
fi

# Reset local scene directory
rm -rf $SCENES_DIR && mkdir -p $SCENES_DIR

# Use a copy of the scene JSON file - in Docker this will co-exist with Chunky JSON files too
ORIGINAL_SCENE_NAME=$(ls "$SCENE_DIR" | grep -v backup | grep -v chunky | grep json)
SCENE_NAME=$(basename $ORIGINAL_SCENE_NAME ".json")
mkdir "$SCENES_DIR/$SCENE_NAME"

# Place scene JSON in expected location for Chunky within a directory with the scene names
SCENE_JSON_PATH="$SCENES_DIR/$SCENE_NAME/$SCENE_NAME.json"
cp "$SCENE_DIR/$SCENE_NAME.json" $SCENE_JSON_PATH

# Manual scene file fixes
# - Set appropriate world directory for the platform to allow chunks to load
# - Empty actors array to prevent NullPointerException in 2.4.0
SCENE_JSON=$(cat $SCENE_JSON_PATH)
NEW_SCENE_JSON="{
  \"world\": {
    \"path\":\"$WORLD_DIR\",
    \"dimension\": 0
  },
  \"actors\": []
}"
echo "$SCENE_JSON $NEW_SCENE_JSON" | jq -s add > $SCENE_JSON_PATH

# Run Chunky
java \
  --module-path "/usr/share/maven-repo/org/openjfx/javafx-controls/11/:/usr/share/maven-repo/org/openjfx/javafx-base/11/:/usr/share/maven-repo/org/openjfx/javafx-graphics/11/:/usr/share/maven-repo/org/openjfx/javafx-fxml/11/" \
  --add-modules=javafx.controls,javafx.base,javafx.graphics,javafx.fxml \
  -Dchunky.home="$(pwd)" \
  -jar ChunkyLauncher.jar \
  -f \
  -target $TARGET_SPP \
  -render $SCENE_NAME
