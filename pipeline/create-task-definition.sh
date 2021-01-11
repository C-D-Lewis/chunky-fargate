#!/bin/bash

set -eu

PROJECT_NAME="chunky-fargate"
ECR_NAME="$PROJECT_NAME-service-ecr"
CPU="2048"
MEMORY="4096"
TASK_DEF_NAME="$PROJECT_NAME-definition"
FAMILY="chunky-fargate-td"

# Max Fargate size
if [[ "$*" == *--max* ]]; then
  CPU="4096"
  MEMORY="8192"
fi

# Get ECR URI
RES=$(aws ecr describe-repositories --repository-names $ECR_NAME)
ECR_URI="$(echo $RES | jq -r '.repositories[0].repositoryUri')"
TARGET="$ECR_URI:latest"

# Get account ID
RES=$(aws sts get-caller-identity)
AWS_ACCOUNT_ID="$(echo $RES | jq -r '.Account')"

# Get role ARNs
RES=$(aws iam get-role --role-name "$PROJECT_NAME-task-execution-role")
EXECUTION_ROLE_ARN=$(echo $RES | jq -r '.Role.Arn')
RES=$(aws iam get-role --role-name "$PROJECT_NAME-task-role")
TASK_ROLE_ARN=$(echo $RES | jq -r '.Role.Arn')

# Create task definition
echo "Creating task definition..."
aws ecs register-task-definition \
  --family $FAMILY \
  --container-definitions "[{ 
    \"name\": \"$TASK_DEF_NAME\",
    \"image\": \"$TARGET\",
    \"cpu\": $CPU,
    \"memory\": $MEMORY,
    \"logConfiguration\": { 
      \"logDriver\": \"awslogs\",
      \"options\": { 
        \"awslogs-group\" : \"/aws/ecs/$PROJECT_NAME-logs\",
        \"awslogs-region\": \"us-east-1\",
        \"awslogs-stream-prefix\": \"ecs\"
      }
    }
  }]" \
  --cpu $CPU \
  --execution-role-arn $EXECUTION_ROLE_ARN \
  --task-role-arn $TASK_ROLE_ARN \
  --memory $MEMORY \
  --network-mode awsvpc \
  --requires-compatibilities "FARGATE"