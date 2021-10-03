#!/bin/bash

set -eu

echo ""
echo "Using bucket $BUCKET"
export TF_VAR_bucket=$BUCKET

echo "Upload trigger enabled? $UPLOAD_TRIGGER_ENABLED"
export TF_VAR_upload_trigger_enabled=$UPLOAD_TRIGGER_ENABLED

echo "Email notifications enabled? $EMAIL_NOTIFICATIONS_ENABLED"
export TF_VAR_email_notifications_enabled=$EMAIL_NOTIFICATIONS_ENABLED

echo ""

# Compile Lambda function
zip -j upload-function.zip lambda/upload-function.js

# Run terraform
cd terraform
terraform init
terraform apply

# Clean up function bundle
rm -rf ./*.zip
