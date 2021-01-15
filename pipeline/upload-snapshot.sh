
#!/bin/bash

set -eu

DATE=$(date +'%Y-%m-%d')
SCENES_DIR="scenes"
SCENE_SNAPSHOT_PATH="$SCENES_DIR/$SCENE_NAME/snapshots"
BUCKET_RENDERS_DIR="chunky-fargate/renders"

RENDER_TIME=$1

# Find file name
PNG_FILE_NAME=$(ls $SCENE_SNAPSHOT_PATH)
BASENAME=$(basename $PNG_FILE_NAME ".png")
SNAPSHOT_PATH="$SCENE_SNAPSHOT_PATH/$BASENAME.png"

# Upload to S3
aws s3 cp \
  $SNAPSHOT_PATH \
  "s3://$BUCKET/$BUCKET_RENDERS_DIR/$DATE/$BASENAME-$RENDER_TIME.png"
