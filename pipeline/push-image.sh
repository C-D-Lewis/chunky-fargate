#!/bin/bash

set -eu

PROJECT_NAME="chunky-fargate"
ECR_NAME="$PROJECT_NAME-service-ecr"
IMAGE="$PROJECT_NAME:latest"
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}

# Login
PWD=$(aws ecr get-login-password --region $AWS_DEFAULT_REGION)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --region=${AWS_DEFAULT_REGION} --query='Account' --output=text)
docker login -u AWS -p "${PWD}" "https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

# Get ECR URI
RES=$(aws ecr describe-repositories --repository-names $ECR_NAME --region $AWS_DEFAULT_REGION)
ECR_URI="$(echo $RES | jq -r '.repositories[0].repositoryUri')"

# Tag as latest
TARGET="$ECR_URI:latest"  # Only want one image in the repo
docker tag $IMAGE $TARGET

# Push image
echo "Pushing to ECR: $TARGET"
docker push $TARGET
echo "Push complete"
