
#!/bin/bash

# env: BUCKET

set -eu

# Current date-time
YEAR=$(date +'%Y')
# Local scenes directory
SCENES_DIR="scenes"
# Path to the snapshots
SCENE_SNAPSHOT_PATH="$SCENES_DIR/$SCENE_NAME/snapshots"
# Directory for renders within the bucket
RENDERS_DIR="chunky-fargate/renders/$YEAR"

# Time the render took, passed from run-all.sh, converted to h-m-s
RENDER_TIME=$1
HOURS=$((RENDER_TIME/3600))
MINS=$((RENDER_TIME%3600/60))
SECS=$((RENDER_TIME%60))
RENDER_TIME="$HOURS-$MINS-$SECS"

# Find the only PNG file by name
PNG_FILE_NAME=$(ls $SCENE_SNAPSHOT_PATH)
BASENAME=$(basename $PNG_FILE_NAME ".png")
SNAPSHOT_PATH="$SCENE_SNAPSHOT_PATH/$BASENAME.png"
DATE=$(date +'%Y%m%d-%H%M%S')

# Upload it to S3
aws s3 cp \
  $SNAPSHOT_PATH \
  "s3://$BUCKET/$RENDERS_DIR/$WORLD_NAME-$BASENAME-$RENDER_TIME-$DATE.png"
