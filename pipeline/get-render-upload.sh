#!/bin/bash

set -eu

# env: WORLD_URL, SCENE_NAME, TARGET_SPP, BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
# ./pipeline.sh

WORLD_DIR="$(pwd)/world"

./fetch-world.sh $WORLD_URL

./render-scene.sh $WORLD_DIR $SCENE_NAME $TARGET_SPP --restart

./upload-snapshot.sh

rm -rf $WORLD_DIR
