#!/bin/bash

set -eu

# env: WORLD_URL, SCENE_NAME, TARGET_SPP, OUTPUT_BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
# ./pipeline.sh

WORLD_DIR="$(pwd)/world"

./pipeline/fetch-world.sh $WORLD_URL

RENDER_START=$(date +%s)
./pipeline/render-scene.sh $WORLD_DIR $SCENE_NAME $TARGET_SPP --restart
RENDER_TIME=$(($(date +%s) - $RENDER_START))

./pipeline/upload.sh $RENDER_TIME

rm -rf $WORLD_DIR
