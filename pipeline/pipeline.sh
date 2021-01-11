#!/bin/bash

set -eu

# env: WORLD_URL, SCENE_NAME, TARGET_SPP, OUTPUT_BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
# ./pipeline.sh

WORLD_DIR="$(pwd)/world"

# Fetch the world zip file
./pipeline/fetch-world.sh $WORLD_URL

# Do the render
RENDER_START=$(date +%s)
./pipeline/render-scene.sh $WORLD_DIR $SCENE_NAME $TARGET_SPP --restart
RENDER_TIME=$(($(date +%s) - $RENDER_START))

# Upload the output snapshot
./pipeline/upload-snapshot.sh $RENDER_TIME

# In case running locally, clean up temporary world
rm -rf $WORLD_DIR
