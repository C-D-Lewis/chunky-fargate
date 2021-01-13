#!/bin/bash

# Run the docker container on a Raspberry Pi
# env: WORLD_NAME, SCENE_NAME, TARGET_SPP, BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION

set -eu

echo ""
read -p "Raspberry Pi IP: " IP

echo "Copying ChunkyLauncher.jar:"
rsync ChunkyLauncher.jar "pi@$IP:/home/pi/ChunkyLauncher.jar"

echo "Connecting to Pi:"
CMD="
rm -rf chunky-fargate
  && git clone https://github.com/c-d-lewis/chunky-fargate
  && cp ChunkyLauncher.jar chunky-fargate/
  && cd chunky-fargate
  && docker build -t chunky-fargate .
  && export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
  && export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
  && export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
  && docker run
    -e \"WORLD_NAME=$WORLD_NAME\"
    -e \"SCENE_NAME=$SCENE_NAME\"
    -e \"TARGET_SPP=$TARGET_SPP\"
    -e \"BUCKET=$BUCKET\"
    -e \"AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION\"
    -e \"AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\"
    -e \"AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\"
    chunky-fargate
"

ssh pi@$IP $CMD
