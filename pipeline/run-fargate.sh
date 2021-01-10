#!/bin/bash

set -eu

PROJECT_NAME="chunky-fargate"
FAMILY="chunky-fargate-td"
CPU="2048"
MEMORY="4096"
ECR_NAME="$PROJECT_NAME-service-ecr"
TASK_DEF_NAME="$PROJECT_NAME-definition"
CLUSTER_NAME="$PROJECT_NAME-ecs-cluster"

# Get ECR URI
RES=$(aws ecr describe-repositories --repository-names $ECR_NAME)
ECR_URI="$(echo $RES | jq -r '.repositories[0].repositoryUri')"
TARGET="$ECR_URI:latest"

# Get account ID
RES=$(aws sts get-caller-identity)
AWS_ACCOUNT_ID="$(echo $RES | jq -r '.Account')"

# Get role ARN
RES=$(aws iam get-role --role-name "$PROJECT_NAME-task-execution-role")
ROLE_ARN=$(echo $RES | jq -r '.Role.Arn')

# Create task definition
echo "Creating task definition..."
aws ecs register-task-definition \
  --family $FAMILY \
  --container-definitions "[{ 
    \"name\": \"$TASK_DEF_NAME\",
    \"image\": \"$TARGET\",
    \"cpu\": $CPU,
    \"memory\": $MEMORY,
    \"environment\": [
      { \"name\": \"WORLD_URL\", \"value\": \"$WORLD_URL\" },
      { \"name\": \"SCENE_NAME\", \"value\": \"$SCENE_NAME\" },
      { \"name\": \"TARGET_SPP\", \"value\": \"$TARGET_SPP\" },
      { \"name\": \"OUTPUT_BUCKET\", \"value\": \"$OUTPUT_BUCKET\" }
    ], 
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
  --execution-role-arn $ROLE_ARN \
  --memory $MEMORY \
  --network-mode awsvpc \
  --requires-compatibilities "FARGATE"

# Get security group
RES=$(aws ec2 describe-security-groups --filters "Name=tag:Project,Values=$PROJECT_NAME")
SECURITY_GROUP_ID=$(echo $RES | jq -r '.SecurityGroups[0].GroupId')

# Get VPC (assuming only one)
RES=$(aws ec2 describe-vpcs)
VPC_ID=$(echo $RES | jq -r '.Vpcs[0].VpcId')

# Get subnets (assume all are public)
RES=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID")
SUBNET_ID=$(echo $RES | jq -r '.Subnets[0].SubnetId')

# Create a task
echo "Creating task..."
aws ecs run-task \
  --cluster $CLUSTER_NAME \
  --task-definition $FAMILY \
  --count 1 \
  --launch-type FARGATE \
  --network-configuration "{
    \"awsvpcConfiguration\": {
      \"subnets\": [\"$SUBNET_ID\"],
      \"securityGroups\": [\"$SECURITY_GROUP_ID\"],
      \"assignPublicIp\": \"ENABLED\"
    }
  }"
