#!/bin/bash

set -eu

# Directory for tasks within the bucket
TASKS_DIR="chunky-fargate/tasks"
# Directory for completed tasks within the bucket
COMPLETED_DIR="chunky-fargate/completed-tasks"

# Move all completed tasks except the placeholder
aws s3 mv "s3://$BUCKET/$TASKS_DIR/" "s3://$BUCKET/$COMPLETED_DIR/" --recursive --exclude "drop-tasks-here"
echo "Moved tasks to completed-tasks"
