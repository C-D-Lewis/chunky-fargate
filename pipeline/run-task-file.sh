#!/bin/bash

set -eu

# Directory for tasks within the bucket
BUCKET_TASKS_DIR="chunky-fargate/tasks"

# Task file name
TASK_FILE=$1

# Fetch task file
aws s3 cp \
  "s3://$BUCKET/$BUCKET_TASKS_DIR/$TASK_FILE" \
  "./$TASK_FILE"

# Check it
BUCKET=$(cat $TASK_FILE | jq -r '.bucket')
WORLD=$(cat $TASK_FILE | jq -r '.world')
SCENES=$(cat $TASK_FILE | jq -r '.scenes')
if [[ "$BUCKET" == "null" ]]; then
  echo "Task is missing .bucket"
  exit 1
fi
if [[ "$WORLD" == "null" ]]; then
  echo "Task is missing .world"
  exit 1
fi
if [[ "$SCENES" == "null" ]]; then
  echo "Task is missing .scenes"
  exit 1
fi
SCENES_LENGTH=$(echo $SCENES | jq -r  length)
if [[ "$SCENES_LENGTH" < "1" ]]; then
  echo "At least one scene needed in .scenes"
  exit 1
fi

# Check each scene to render and launch Fargate
jq -c -r '.[]' <<< "$SCENES" | while read SCENE_JSON; do
  SCENE_NAME=$(echo $SCENE_JSON | jq -r '.name')
  TARGET_SPP=$(echo $SCENE_JSON | jq -r '.targetSpp')

  if [[ "$SCENE_NAME" == "null" ]]; then
    echo "Scene is missing .name"
    exit 1
  fi
  if [[ "$TARGET_SPP" == "null" ]]; then
    echo "Scene is missing .targetSpp"
    exit 1
  fi

  # Launch a task
  echo "Launching $SCENE_NAME in $WORLD @ $TARGET_SPP SPP"
  ./pipeline/run-fargate.sh $BUCKET $WORLD $SCENE_NAME $TARGET_SPP
done

# Cleanup
rm $TASK_FILE
