
#!/bin/bash

set -eu

SCENES_DIR="$(pwd)/scenes"
SCENE_PATH="$SCENES_DIR/$SCENE_NAME"
BUCKET_SCENES_DIR="chunky-fargate/scenes"

mkdir -p $SCENE_PATH

# Download scene JSON file from S3 - permissions are in the environment
aws s3 cp \
  "s3://$BUCKET/$BUCKET_SCENES_DIR/$SCENE_NAME.json" \
  "$SCENE_PATH/$SCENE_NAME.json"
