#!/bin/bash

set -eu

PROJECT_NAME="chunky-fargate"
ECR_NAME="$PROJECT_NAME-service-ecr"
IMAGE="$PROJECT_NAME:latest"

# Login
$(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)

# Get ECR URI
RES=$(aws ecr describe-repositories --repository-names $ECR_NAME)
ECR_URI="$(echo $RES | jq -r '.repositories[0].repositoryUri')"

# Tag as latest
TARGET="$ECR_URI:latest"  # Only want one image in the repo
docker tag $IMAGE $TARGET

# Push image
echo "Pushing to ECR: $TARGET"
docker push $TARGET
echo "Push complete"
