#!/bin/bash

# AWS Admin Dashboard Cleanup Script
# This script removes all resources created by the deployment

set -e

# Configuration
AWS_REGION="eu-west-2"  # London region
TERRAFORM_STATE_BUCKET="terraform-state-admin-dashboard"
TERRAFORM_LOCK_TABLE="terraform-lock-table"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check AWS CLI configuration
check_aws_config() {
    echo -e "${YELLOW}Checking AWS CLI configuration...${NC}"
    
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not installed${NC}"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not configured properly${NC}"
        echo -e "${YELLOW}Please run 'aws configure' and set up your credentials${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}AWS CLI is properly configured${NC}"
}

# Function to delete S3 bucket
delete_s3_bucket() {
    echo -e "${YELLOW}Deleting S3 bucket...${NC}"
    
    # Check if bucket exists
    if aws s3api head-bucket --bucket $TERRAFORM_STATE_BUCKET 2>/dev/null; then
        echo -e "${YELLOW}Emptying bucket: $TERRAFORM_STATE_BUCKET${NC}"
        aws s3 rm s3://$TERRAFORM_STATE_BUCKET --recursive || true
        
        echo -e "${YELLOW}Deleting bucket: $TERRAFORM_STATE_BUCKET${NC}"
        aws s3api delete-bucket \
            --bucket $TERRAFORM_STATE_BUCKET \
            --region $AWS_REGION || true
        
        echo -e "${GREEN}S3 bucket deleted successfully${NC}"
    else
        echo -e "${YELLOW}S3 bucket $TERRAFORM_STATE_BUCKET does not exist${NC}"
    fi
}

# Function to delete DynamoDB table
delete_dynamodb_table() {
    echo -e "${YELLOW}Deleting DynamoDB table...${NC}"
    
    # Check if table exists
    if aws dynamodb describe-table --table-name $TERRAFORM_LOCK_TABLE 2>/dev/null; then
        echo -e "${YELLOW}Deleting table: $TERRAFORM_LOCK_TABLE${NC}"
        aws dynamodb delete-table \
            --table-name $TERRAFORM_LOCK_TABLE \
            --region $AWS_REGION || true
        
        echo -e "${GREEN}DynamoDB table deleted successfully${NC}"
    else
        echo -e "${YELLOW}DynamoDB table $TERRAFORM_LOCK_TABLE does not exist${NC}"
    fi
}

# Function to delete CloudWatch resources
delete_cloudwatch_resources() {
    echo -e "${YELLOW}Deleting CloudWatch resources...${NC}"
    
    # Delete log groups
    echo -e "${YELLOW}Checking for CloudWatch log groups...${NC}"
    aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text | \
    grep "admin-dashboard" | \
    while read -r log_group; do
        echo -e "${YELLOW}Deleting log group: $log_group${NC}"
        aws logs delete-log-group --log-group-name "$log_group" || true
    done
    
    # Delete dashboards
    echo -e "${YELLOW}Checking for CloudWatch dashboards...${NC}"
    if aws cloudwatch list-dashboards --query 'DashboardEntries[*].DashboardName' --output text | grep -q "admin-dashboard"; then
        echo -e "${YELLOW}Deleting dashboard: admin-dashboard${NC}"
        aws cloudwatch delete-dashboards --dashboard-names "admin-dashboard" || true
    fi
    
    # Delete alarms
    echo -e "${YELLOW}Checking for CloudWatch alarms...${NC}"
    aws cloudwatch describe-alarms --query 'MetricAlarms[*].AlarmName' --output text | \
    grep "admin-dashboard" | \
    while read -r alarm; do
        echo -e "${YELLOW}Deleting alarm: $alarm${NC}"
        aws cloudwatch delete-alarms --alarm-names "$alarm" || true
    done
    
    echo -e "${GREEN}CloudWatch resources deleted successfully${NC}"
}

# Function to delete SNS topics
delete_sns_topics() {
    echo -e "${YELLOW}Deleting SNS topics...${NC}"
    
    echo -e "${YELLOW}Checking for SNS topics...${NC}"
    aws sns list-topics --query 'Topics[*].TopicArn' --output text | \
    grep "monitoring-alerts" | \
    while read -r topic_arn; do
        echo -e "${YELLOW}Deleting topic: $topic_arn${NC}"
        aws sns delete-topic --topic-arn "$topic_arn" || true
    done
    
    echo -e "${GREEN}SNS topics deleted successfully${NC}"
}

# Function to delete IAM resources
delete_iam_resources() {
    echo -e "${YELLOW}Deleting IAM resources...${NC}"
    
    # Delete policies
    echo -e "${YELLOW}Checking for IAM policies...${NC}"
    aws iam list-policies --query 'Policies[*].Arn' --output text | \
    grep "admin-dashboard" | \
    while read -r policy_arn; do
        echo -e "${YELLOW}Deleting policy: $policy_arn${NC}"
        aws iam delete-policy --policy-arn "$policy_arn" || true
    done
    
    # Delete roles
    echo -e "${YELLOW}Checking for IAM roles...${NC}"
    aws iam list-roles --query 'Roles[*].RoleName' --output text | \
    grep "admin-dashboard" | \
    while read -r role_name; do
        echo -e "${YELLOW}Processing role: $role_name${NC}"
        # Detach policies first
        aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[*].PolicyArn' --output text | \
        while read -r policy_arn; do
            echo -e "${YELLOW}Detaching policy: $policy_arn from role: $role_name${NC}"
            aws iam detach-role-policy --role-name "$role_name" --policy-arn "$policy_arn" || true
        done
        echo -e "${YELLOW}Deleting role: $role_name${NC}"
        aws iam delete-role --role-name "$role_name" || true
    done
    
    echo -e "${GREEN}IAM resources deleted successfully${NC}"
}

# Function to delete EC2 resources
delete_ec2_resources() {
    echo -e "${YELLOW}Deleting EC2 resources...${NC}"
    
    # Terminate instances
    echo -e "${YELLOW}Checking for EC2 instances...${NC}"
    aws ec2 describe-instances --filters "Name=tag:Project,Values=Admin-Dashboard" --query 'Reservations[*].Instances[*].InstanceId' --output text | \
    while read -r instance_id; do
        echo -e "${YELLOW}Terminating instance: $instance_id${NC}"
        aws ec2 terminate-instances --instance-ids "$instance_id" || true
    done
    
    # Delete security groups
    echo -e "${YELLOW}Checking for security groups...${NC}"
    aws ec2 describe-security-groups --filters "Name=group-name,Values=admin-dashboard*" --query 'SecurityGroups[*].GroupId' --output text | \
    while read -r sg_id; do
        echo -e "${YELLOW}Deleting security group: $sg_id${NC}"
        aws ec2 delete-security-group --group-id "$sg_id" || true
    done
    
    echo -e "${GREEN}EC2 resources deleted successfully${NC}"
}

# Function to delete RDS resources
delete_rds_resources() {
    echo -e "${YELLOW}Deleting RDS resources...${NC}"
    
    echo -e "${YELLOW}Checking for RDS instances...${NC}"
    aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text | \
    grep "admin-dashboard" | \
    while read -r db_instance; do
        echo -e "${YELLOW}Deleting RDS instance: $db_instance${NC}"
        aws rds delete-db-instance \
            --db-instance-identifier "$db_instance" \
            --skip-final-snapshot \
            --delete-automated-backups || true
    done
    
    echo -e "${GREEN}RDS resources deleted successfully${NC}"
}

# Function to delete Lambda resources
delete_lambda_resources() {
    echo -e "${YELLOW}Deleting Lambda resources...${NC}"
    
    echo -e "${YELLOW}Checking for Lambda functions...${NC}"
    aws lambda list-functions --query 'Functions[*].FunctionName' --output text | \
    grep "admin-dashboard" | \
    while read -r function_name; do
        echo -e "${YELLOW}Deleting function: $function_name${NC}"
        aws lambda delete-function --function-name "$function_name" || true
    done
    
    echo -e "${GREEN}Lambda resources deleted successfully${NC}"
}

# Function to delete S3 resources
delete_s3_resources() {
    echo -e "${YELLOW}Deleting S3 resources...${NC}"
    
    echo -e "${YELLOW}Checking for S3 buckets...${NC}"
    aws s3api list-buckets --query 'Buckets[*].Name' --output text | \
    grep "admin-dashboard" | \
    while read -r bucket_name; do
        echo -e "${YELLOW}Processing bucket: $bucket_name${NC}"
        # Empty the bucket first
        echo -e "${YELLOW}Emptying bucket: $bucket_name${NC}"
        aws s3 rm s3://$bucket_name --recursive || true
        # Delete the bucket
        echo -e "${YELLOW}Deleting bucket: $bucket_name${NC}"
        aws s3api delete-bucket --bucket $bucket_name --region $AWS_REGION || true
    done
    
    echo -e "${GREEN}S3 resources deleted successfully${NC}"
}

# Main cleanup process
main() {
    echo -e "${GREEN}Starting cleanup of AWS Admin Dashboard resources...${NC}"
    
    # Check AWS CLI configuration first
    check_aws_config
    
    # Delete resources in reverse order of creation
    delete_cloudwatch_resources
    delete_sns_topics
    delete_iam_resources
    delete_ec2_resources
    delete_rds_resources
    delete_lambda_resources
    delete_s3_resources
    delete_dynamodb_table
    delete_s3_bucket
    
    echo -e "${GREEN}Cleanup completed successfully!${NC}"
    echo -e "${YELLOW}Note: Some resources may take a few minutes to be completely removed${NC}"
}

# Execute main function
main 