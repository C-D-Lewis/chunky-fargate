
#!/bin/bash

set -eu

SCENES_DIR="scenes"
SCENE_PATH="$SCENES_DIR/$SCENE_NAME"
BUCKET_DIR_NAME="mc-scenes"

mkdir -p $SCENE_PATH

# Download scene JSON file from S3 - permissions are in the environment
aws s3 cp \
  "s3://$OUTPUT_BUCKET/$BUCKET_DIR_NAME/$SCENE_NAME.json" \
  "$SCENE_PATH/$SCENE_NAME.json"
