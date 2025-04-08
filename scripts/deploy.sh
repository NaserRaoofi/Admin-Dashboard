#!/bin/bash

# AWS Admin Dashboard Deployment Script
# This script handles the deployment of basic monitoring infrastructure
# Optimized for learning purposes with minimal costs

set -e

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
ENVIRONMENT=${1:-"prod"}
AWS_REGION=${2:-"eu-west-2"}  # London region
TERRAFORM_VERSION="1.0.0"
TERRAFORM_STATE_BUCKET="terraform-state-admin-dashboard"  # Fixed bucket name
TERRAFORM_LOCK_TABLE="terraform-lock-table"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to validate AWS region
validate_region() {
    echo -e "${YELLOW}Validating AWS region...${NC}"
    
    # Check if region is eu-west-2
    if [ "$AWS_REGION" != "eu-west-2" ]; then
        echo -e "${RED}Error: This deployment is configured for eu-west-2 (London) region only${NC}"
        echo -e "${YELLOW}Please use: ./deploy.sh prod eu-west-2${NC}"
        exit 1
    fi
    
    # Verify region exists and is accessible
    if ! aws ec2 describe-availability-zones --region $AWS_REGION &> /dev/null; then
        echo -e "${RED}Error: Region $AWS_REGION is not accessible or does not exist${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Region $AWS_REGION validated successfully${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not installed${NC}"
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}Error: Terraform is not installed${NC}"
        exit 1
    fi
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    if [[ "$TF_VERSION" < "$TERRAFORM_VERSION" ]]; then
        echo -e "${RED}Error: Terraform version $TERRAFORM_VERSION or higher is required${NC}"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}Error: AWS credentials are not configured${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All prerequisites met${NC}"
}

# Function to initialize Terraform
init_terraform() {
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    
    # Change to the environment directory
    cd "$PROJECT_ROOT/environments/$ENVIRONMENT"
    
    # Check if the directory exists
    if [ ! -d "$PROJECT_ROOT/environments/$ENVIRONMENT" ]; then
        echo -e "${RED}Error: Environment directory $ENVIRONMENT not found${NC}"
        exit 1
    fi
    
    # Check if S3 bucket exists
    if ! aws s3api head-bucket --bucket $TERRAFORM_STATE_BUCKET 2>/dev/null; then
        echo -e "${RED}Error: S3 bucket $TERRAFORM_STATE_BUCKET does not exist${NC}"
        echo -e "${YELLOW}Please run ./setup_backend.sh first to create the required infrastructure${NC}"
        exit 1
    fi
    
    terraform init \
        -backend-config="bucket=$TERRAFORM_STATE_BUCKET" \
        -backend-config="dynamodb_table=$TERRAFORM_LOCK_TABLE" \
        -backend-config="region=$AWS_REGION" \
        -backend-config="key=$ENVIRONMENT/terraform.tfstate"
    
    echo -e "${GREEN}Terraform initialized successfully${NC}"
}

# Function to validate Terraform configuration
validate_terraform() {
    echo -e "${YELLOW}Validating Terraform configuration...${NC}"
    
    terraform validate
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Terraform configuration is valid${NC}"
    else
        echo -e "${RED}Error: Terraform configuration validation failed${NC}"
        exit 1
    fi
}

# Function to plan Terraform changes
plan_terraform() {
    echo -e "${YELLOW}Planning Terraform changes...${NC}"
    
    terraform plan \
        -var="aws_region=$AWS_REGION" \
        -var="environment=$ENVIRONMENT" \
        -var="enable_advanced_monitoring=false" \
        -var="enable_guardduty=false" \
        -var="enable_security_hub=false" \
        -var="enable_cloudwatch_agent=false" \
        -out=tfplan
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Terraform plan created successfully${NC}"
    else
        echo -e "${RED}Error: Terraform plan failed${NC}"
        exit 1
    fi
}

# Function to apply Terraform changes
apply_terraform() {
    echo -e "${YELLOW}Applying Terraform changes...${NC}"
    
    terraform apply tfplan
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Terraform changes applied successfully${NC}"
    else
        echo -e "${RED}Error: Terraform apply failed${NC}"
        exit 1
    fi
}

# Function to verify AWS services
verify_aws_services() {
    echo -e "${YELLOW}Verifying AWS services...${NC}"
    
    # Check CloudWatch
    if ! aws cloudwatch describe-alarms --region $AWS_REGION &> /dev/null; then
        echo -e "${RED}Error: CloudWatch service is not accessible${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}AWS services verified${NC}"
}

# Function to verify monitoring setup
verify_monitoring() {
    echo -e "${YELLOW}Verifying monitoring setup...${NC}"
    
    # Check basic CloudWatch metrics
    if ! aws cloudwatch list-metrics --namespace "AWS/EC2" --query 'length(Metrics)' --output text &> /dev/null; then
        echo -e "${YELLOW}Warning: Basic EC2 metrics not found${NC}"
    fi
    
    echo -e "${GREEN}Basic monitoring setup verified${NC}"
}

# Main deployment process
main() {
    echo -e "${GREEN}Starting AWS Admin Dashboard deployment (Basic monitoring only)...${NC}"
    echo -e "${YELLOW}Note: This deployment uses only basic free monitoring features for learning purposes${NC}"
    
    validate_region
    check_prerequisites
    verify_aws_services
    init_terraform
    validate_terraform
    plan_terraform
    apply_terraform
    verify_monitoring
    
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo -e "${YELLOW}Note: Only basic free monitoring features are enabled to minimize costs${NC}"
}

# Execute main function
main 