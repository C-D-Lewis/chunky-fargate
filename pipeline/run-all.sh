#!/bin/bash

set -eu

# env: WORLD_NAME, SCENE_NAME, TARGET_SPP, BUCKET, [AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY|AWS_PROFILE|IAM], AWS_DEFAULT_REGION
# ./pipeline.sh

WORLD_DIR="$(pwd)/world"
SCENES_DIR="$(pwd)/scenes"

# Fetch the scene JSON file
echo "Downloading scene"
./pipeline/fetch-scene.sh

# Fetch the world zip file
echo "Downloading world"
./pipeline/fetch-world.sh

# Do the render, tail logs
RENDER_START=$(date +%s)
./pipeline/render-scene.sh $WORLD_DIR "." $TARGET_SPP
RENDER_TIME=$(($(date +%s) - $RENDER_START))

# Upload the output snapshot
echo "Uploading snapshot"
./pipeline/upload-snapshot.sh $RENDER_TIME

# Move completed tasks
# ./pipeline/move-completed-tasks.sh

# Notify SNS topic for email notifications
./pipeline/notify-sns.sh

# In case running locally, clean up temporary world
rm -rf $WORLD_DIR
rm -rf $SCENES_DIR
