#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check service availability
check_service() {
    service_name=$1
    description=$2
    
    echo -e "\nChecking ${YELLOW}$description${NC}..."
    
    # Use AWS CLI to check if service is accessible
    if aws $service_name describe-regions 2>/dev/null; then
        echo -e "${GREEN}✓ $description is available${NC}"
        return 0
    else
        echo -e "${RED}✗ $description is not available${NC}"
        return 1
    fi
}

# Check AWS CLI installation
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials are not configured. Please configure them first.${NC}"
    exit 1
fi

# Array of services to check
declare -A services=(
    ["ec2"]="EC2 Service"
    ["rds"]="RDS Service"
    ["s3"]="S3 Service"
    ["lambda"]="Lambda Service"
    ["iam"]="IAM Service"
    ["elasticloadbalancing"]="Elastic Load Balancing"
    ["cloudwatch"]="CloudWatch Service"
    ["cloudtrail"]="CloudTrail Service"
)

# Results array for available services
declare -a available_services=()

echo "Starting AWS services availability check..."

# Check each service
for service in "${!services[@]}"; do
    if check_service "$service" "${services[$service]}"; then
        available_services+=("$service")
    fi
done

# Create terraform.tfvars with available services
echo "# Available services configuration" > ../terraform.tfvars
echo "available_services = [" >> ../terraform.tfvars
for service in "${available_services[@]}"; do
    echo "  \"$service\"," >> ../terraform.tfvars
done
echo "]" >> ../terraform.tfvars

echo -e "\n${GREEN}Service check completed. Results written to terraform.tfvars${NC}" 