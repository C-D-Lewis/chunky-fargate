
#!/bin/bash

set -eu

BUCKET_SCENES_DIR="chunky-fargate/scenes"

# Download scene JSON file from S3 - permissions are in the environment
aws s3 cp \
  "s3://$BUCKET/$BUCKET_SCENES_DIR/$SCENE_NAME.json" \
  "./$SCENE_NAME.json"
