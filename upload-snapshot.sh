
#!/bin/bash

set -eu

DATE=$(date +'%m-%d-%Y')
SCENES_DIR="scenes"
SCENE_SNAPSHOT_PATH="$SCENES_DIR/$SCENE_NAME/snapshots"
DIR_NAME="mc-renders"

# Upload to S3 - permissions are in the environment
aws s3 sync $SCENE_SNAPSHOT_PATH $BUCKET/$DIR_NAME/$SCENE_NAME/$DATE/
