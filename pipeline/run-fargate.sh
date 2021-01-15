#!/bin/bash

PROJECT_NAME="chunky-fargate"
FAMILY="chunky-fargate-td"
TASK_DEF_NAME="$PROJECT_NAME-container-def"
CLUSTER_NAME="$PROJECT_NAME-ecs-cluster"

# If no params, ask for them
if [ $# -eq 0 ]; then
  echo ""
  read -p "World name: " WORLD_NAME
  read -p "Scene name: " SCENE_NAME
  read -p "Target SPP: " TARGET_SPP
  read -p "S3 bucket: s3://" BUCKET
  echo ""
else
  BUCKET=$1
  WORLD_NAME=$2
  SCENE_NAME=$3
  TARGET_SPP=$4
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
RES=$(aws ecs run-task \
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
        { \"name\": \"WORLD_NAME\", \"value\": \"$WORLD_NAME\" },
        { \"name\": \"SCENE_NAME\", \"value\": \"$SCENE_NAME\" },
        { \"name\": \"TARGET_SPP\", \"value\": \"$TARGET_SPP\" },
        { \"name\": \"BUCKET\", \"value\": \"$BUCKET\" }
      ]
    }]
  }" \
)

TASK_ID=$(echo $RES | jq -r '.tasks[0].taskArn')
echo "Started: $TASK_ID"
echo ""
