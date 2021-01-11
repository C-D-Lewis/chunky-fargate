
#!/bin/bash

set -eu

DATE=$(date +'%m-%d-%Y')
SCENES_DIR="scenes"
SCENE_SNAPSHOT_PATH="$SCENES_DIR/$SCENE_NAME/snapshots"
DIR_NAME="mc-renders"

RENDER_TIME=$1

# Add time taken to file
PNG_FILE_NAME=$(ls $SCENE_SNAPSHOT_PATH)
BASENAME=$(basename $PNG_FILE_NAME ".png")
mv "$SCENE_SNAPSHOT_PATH/$PNG_FILE_NAME" "$SCENE_SNAPSHOT_PATH/$BASENAME-$RENDER_TIME.png"

# Upload to S3 - permissions are in the environment
aws s3 sync $SCENE_SNAPSHOT_PATH $OUTPUT_BUCKET/$DIR_NAME/$SCENE_NAME/$DATE/
