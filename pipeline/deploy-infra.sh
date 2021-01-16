#!/bin/bash

set -eu

echo "Using bucket $BUCKET"
export TF_VAR_bucket=$BUCKET

UPLOAD_TRIGGER_ENABLED=${UPLOAD_TRIGGER_ENABLED:-"false"}
echo "Upload trigger enabled? $UPLOAD_TRIGGER_ENABLED"
export TF_VAR_upload_trigger_enabled=$UPLOAD_TRIGGER_ENABLED

# Compile Lambda functions
zip -j upload-function.zip lambda/upload-function.js

# Terraform
cd terraform
terraform init
terraform apply

# Clean up
rm -rf ./*.zip
