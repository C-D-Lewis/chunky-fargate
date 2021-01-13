#!/bin/bash

PROJECT_NAME="chunky-fargate"
FAMILY="chunky-fargate-td"
TASK_DEF_NAME="$PROJECT_NAME-container-def"
CLUSTER_NAME="$PROJECT_NAME-ecs-cluster"

if [[ "$*" == "--use-env" ]]; then
  echo "Using environment variables:"
  set -eu
  echo "  World zip URL: $WORLD_URL"
  echo "  Scene name: $SCENE_NAME"
  echo "  Target SPP: $TARGET_SPP"
  echo "  Output S3 bucket: s3://$OUTPUT_BUCKET"
else
  read -p "World zip URL: " WORLD_URL
  read -p "Scene name: " SCENE_NAME
  read -p "Target SPP: " TARGET_SPP
  read -p "Output S3 bucket: s3://" OUTPUT_BUCKET
fi

echo "Fetching required resources..."

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
  }" \
  --overrides "{
    \"containerOverrides\": [{
      \"name\": \"$TASK_DEF_NAME\",
      \"environment\": [
        { \"name\": \"WORLD_URL\", \"value\": \"$WORLD_URL\" },
        { \"name\": \"SCENE_NAME\", \"value\": \"$SCENE_NAME\" },
        { \"name\": \"TARGET_SPP\", \"value\": \"$TARGET_SPP\" },
        { \"name\": \"OUTPUT_BUCKET\", \"value\": \"$OUTPUT_BUCKET\" }
      ]
    }]
  }"
