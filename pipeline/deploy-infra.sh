#!/bin/bash

set -eu

echo "Using bucket $BUCKET"

# Compile Lambda functions
zip -j function.zip lambda/upload-function.js

# Terraform
terraform init
terraform apply
