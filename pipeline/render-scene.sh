#!/bin/bash

# Use Chunky 2 manually downloaded jar, copied here
#
# Install dependencies:
#   sudo apt-get install default-jdk libopenjfx-java libcontrolsfx-java jq
#
# Usage:
#   1. Copy scene directories to './scenes'
#   2. Run ./pipeline/render-scene.sh $worldDir $sceneDir $targetSpp
#
# Example:
#   ./pipeline/render-scene.sh "/mnt/c/Users/Chris/Desktop/village-day-8" "/mnt/c/Users/Chris/.chunky/scenes/village-iso" "300"

set -eu

MC_VERSION="1.16.4"
SCENES_DIR="./scenes"

WORLD_DIR=$1
ORIGINAL_SCENE_DIR=$2
TARGET_SPP=$3

# First time setup
if [[ ! -d "resources" ]]; then
  java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar --update
  java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar -download-mc $MC_VERSION
fi

# Use a copy of the scene JSON file
rm -rf $SCENES_DIR && mkdir -p $SCENES_DIR
ORIGINAL_SCENE_NAME=$(ls "$ORIGINAL_SCENE_DIR" | grep -v backup | grep json)
SCENE_NAME=$(basename $ORIGINAL_SCENE_NAME ".json")
mkdir "$SCENES_DIR/$SCENE_NAME"
SCENE_JSON_PATH="$SCENES_DIR/$SCENE_NAME/$SCENE_NAME.json"
cp "$ORIGINAL_SCENE_DIR/$SCENE_NAME.json" $SCENE_JSON_PATH

# Set appropriate world directory for the platform to allow chunks to load
SCENE_JSON=$(cat $SCENE_JSON_PATH)
NEW_WORLD_JSON="{ \"world\": { \"path\":\"$WORLD_DIR\", \"dimension\": 0 } }"
echo "$SCENE_JSON $NEW_WORLD_JSON" | jq -s add > $SCENE_JSON_PATH

# Run Chunky
java \
  --module-path "/usr/share/maven-repo/org/openjfx/javafx-controls/11/:/usr/share/maven-repo/org/openjfx/javafx-base/11/:/usr/share/maven-repo/org/openjfx/javafx-graphics/11/:/usr/share/maven-repo/org/openjfx/javafx-fxml/11/" \
  --add-modules=javafx.controls,javafx.base,javafx.graphics,javafx.fxml \
  -Dchunky.home="$(pwd)" \
  -jar ChunkyLauncher.jar \
  -f \
  -target $TARGET_SPP \
  -render $SCENE_NAME
