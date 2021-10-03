#!/bin/bash

set -eu

echo "Using bucket $BUCKET"
export TF_VAR_bucket=$BUCKET

echo "Upload trigger enabled? $UPLOAD_TRIGGER_ENABLED"
export TF_VAR_upload_trigger_enabled=$UPLOAD_TRIGGER_ENABLED

# Compile Lambda function
zip -j upload-function.zip lambda/upload-function.js

# Run terraform
cd terraform
terraform init
terraform apply

# Clean up function bundle
rm -rf ./*.zip
