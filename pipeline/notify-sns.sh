#!/bin/bash

set -eu

# Get account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --region=${AWS_DEFAULT_REGION} --query='Account' --output=text)
TOPIC_ARN=arn:aws:sns:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:chunky-fargate-sns-topic

# Find the SNS topic, if it's deployed
RES=$(aws sns list-topics)
if [[ ! $RES =~ "$TOPIC_ARN" ]]; then
  echo ">>> Topic not deployed, skipping notification"
  exit 0
fi

# Send notification
echo ">>> Notifying $TOPIC_ARN"
aws sns publish \
  --topic-arn $TOPIC_ARN \
  --message "Render job complete - world:$WORLD_NAME scene:$SCENE_NAME. Check the chosen bucket for the output render file." \
  --subject "chunky-fargate job \"$WORLD_NAME:$SCENE_NAME\" completed"
