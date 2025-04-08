#!/bin/bash

# Script to set up Terraform backend infrastructure
# Creates S3 bucket and DynamoDB table for state management

set -e

# Configuration
AWS_REGION="eu-west-2"  # London region
BUCKET_NAME="terraform-state-admin-dashboard"  # Fixed bucket name
DYNAMODB_TABLE="terraform-lock-table"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to create S3 bucket
create_s3_bucket() {
    echo -e "${YELLOW}Creating S3 bucket for Terraform state...${NC}"
    
    # Check if bucket already exists
    if aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
        echo -e "${YELLOW}S3 bucket $BUCKET_NAME already exists${NC}"
        return
    fi
    
    # Create bucket
    aws s3api create-bucket \
        --bucket $BUCKET_NAME \
        --region $AWS_REGION \
        --create-bucket-configuration LocationConstraint=$AWS_REGION
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket $BUCKET_NAME \
        --versioning-configuration Status=Enabled
    
    # Enable server-side encryption
    aws s3api put-bucket-encryption \
        --bucket $BUCKET_NAME \
        --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
    
    echo -e "${GREEN}S3 bucket created successfully: $BUCKET_NAME${NC}"
}

# Function to create DynamoDB table
create_dynamodb_table() {
    echo -e "${YELLOW}Creating DynamoDB table for state locking...${NC}"
    
    # Check if table already exists
    if aws dynamodb describe-table --table-name $DYNAMODB_TABLE 2>/dev/null; then
        echo -e "${YELLOW}DynamoDB table $DYNAMODB_TABLE already exists${NC}"
        return
    fi
    
    aws dynamodb create-table \
        --table-name $DYNAMODB_TABLE \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region $AWS_REGION
    
    echo -e "${GREEN}DynamoDB table created successfully: $DYNAMODB_TABLE${NC}"
}

# Main execution
main() {
    echo -e "${GREEN}Setting up Terraform backend infrastructure...${NC}"
    
    create_s3_bucket
    create_dynamodb_table
    
    echo -e "${GREEN}Backend infrastructure setup completed!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Run ./deploy.sh to deploy your infrastructure"
    echo "2. The state will be stored in S3 bucket: $BUCKET_NAME"
    echo "3. State locking is handled by DynamoDB table: $DYNAMODB_TABLE"
}

# Execute main function
main 