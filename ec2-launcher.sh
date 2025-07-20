#!/bin/bash

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="ec2_creation.log"
START_TIME=$(date +%s)

echo -e "${CYAN}-------------------------------------"
echo "   EC2 Instance Creation Wizard"
echo -e "-------------------------------------${NC}"

# Fetch default region
DEFAULT_REGION=$(aws configure get region)
echo -e "${YELLOW}Using region:${NC} ${DEFAULT_REGION}"

# Prompt user for values
read -p "Enter EC2 instance name [MyInstance]: " INSTANCE_NAME
INSTANCE_NAME=${INSTANCE_NAME:-MyInstance}

read -p "Enter AMI ID [ami-0c02fb55956c7d316]: " AMI_ID
AMI_ID=${AMI_ID:-ami-0c02fb55956c7d316}

read -p "Enter instance type [t2.micro]: " INSTANCE_TYPE
INSTANCE_TYPE=${INSTANCE_TYPE:-t2.micro}

read -p "Enter key pair name (must exist): " KEY_NAME
if [[ -z "$KEY_NAME" ]]; then
  echo -e "${RED}❌ Key pair name is required.${NC}"
  exit 1
fi

# Prompt for SG ID or auto-create
read -p "Enter security group ID (e.g., sg-xxxx) [Leave blank to auto-create one]: " SG_ID

if [[ -z "$SG_ID" ]]; then
    SG_NAME="auto-created-sg-$(date +%s)"
    echo -e "${YELLOW}⚠️  No security group provided. Creating one named: ${SG_NAME}${NC}"

    SG_ID=$(aws ec2 create-security-group \
        --group-name "$SG_NAME" \
        --description "Auto-created SG by EC2 launcher script" \
        --region "$DEFAULT_REGION" \
        --query 'GroupId' \
        --output text)

    if [[ -z "$SG_ID" || "$SG_ID" == "None" ]]; then
        echo -e "${RED}❌ Failed to create security group.${NC}"
        exit 1
    fi

    MY_IP=$(curl -s https://checkip.amazonaws.com)
    if [[ -z "$MY_IP" ]]; then
        echo -e "${RED}❌ Failed to detect your public IP address.${NC}"
        exit 1
    fi

    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol tcp \
        --port 22 \
        --cidr "$MY_IP/32" \
        --region "$DEFAULT_REGION"

    echo -e "${GREEN}✅ Created SG $SG_ID with SSH access from $MY_IP${NC}"
fi

# Prompt for subnet or auto-detect from default VPC
read -p "Enter subnet ID (optional): " SUBNET_ID

if [[ -z "$SUBNET_ID" ]]; then
    echo -e "${YELLOW}🔍 No subnet provided. Trying to find one in default VPC...${NC}"
    DEFAULT_VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=isDefault,Values=true" \
        --query "Vpcs[0].VpcId" \
        --region "$DEFAULT_REGION" \
        --output text)

    SUBNET_ID=$(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" \
        --query "Subnets[0].SubnetId" \
        --region "$DEFAULT_REGION" \
        --output text)

    if [[ -z "$SUBNET_ID" || "$SUBNET_ID" == "None" ]]; then
        echo -e "${RED}❌ Could not find a subnet in the default VPC. Please create one or provide manually.${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Using subnet: $SUBNET_ID${NC}"
    fi
fi

echo -e "\n${CYAN}🚀 Launching EC2 instance...${NC}"
{
    CMD="aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-group-ids $SG_ID \
        --subnet-id $SUBNET_ID \
        --region $DEFAULT_REGION \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]'"

    eval "$CMD" > output.json
} || {
    echo -e "${RED}❌ Failed to launch instance.${NC}"
    exit 1
}

INSTANCE_ID=$(jq -r '.Instances[0].InstanceId' output.json)
if [[ "$INSTANCE_ID" == "null" || -z "$INSTANCE_ID" ]]; then
    echo -e "${RED}❌ Could not retrieve instance ID.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Instance launched successfully!"
echo -e "🆔 Instance ID: $INSTANCE_ID${NC}"
echo "🔐 Key Pair: $KEY_NAME" | tee -a $LOG_FILE
echo "📦 AMI ID: $AMI_ID" | tee -a $LOG_FILE

echo -e "${YELLOW}⏳ Waiting for instance to be in 'running' state...${NC}"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

INSTANCE_DESC=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --output json)
PUBLIC_IP=$(echo "$INSTANCE_DESC" | jq -r '.Reservations[0].Instances[0].PublicIpAddress')
STATE=$(echo "$INSTANCE_DESC" | jq -r '.Reservations[0].Instances[0].State.Name')
LAUNCH_TIME=$(echo "$INSTANCE_DESC" | jq -r '.Reservations[0].Instances[0].LaunchTime')

echo -e "${GREEN}🚀 Instance Details:"
echo "📍 State: $STATE"
echo "🌐 Public IP: $PUBLIC_IP"
echo "🕒 Launch Time: $LAUNCH_TIME${NC}"

# Ask if user wants to SSH into the instance
read -p "🔐 Do you want to SSH into the instance now? (yes/no): " SSH_CHOICE

if [[ "$SSH_CHOICE" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
    if [[ -z "$PUBLIC_IP" || "$PUBLIC_IP" == "None" ]]; then
        echo -e "${RED}❌ No public IP assigned. Cannot SSH into the instance.${NC}"
    else
        read -p "📁 Enter the path to your private key (.pem file): " PEM_PATH

        if [[ ! -f "$PEM_PATH" ]]; then
            echo -e "${RED}❌ Key file not found at $PEM_PATH${NC}"
            exit 1
        fi

        echo -e "${CYAN}🔗 Connecting to the instance via SSH...${NC}"
        chmod 400 "$PEM_PATH"
        ssh -i "$PEM_PATH" ec2-user@"$PUBLIC_IP"
    fi
else
    echo -e "${YELLOW}🛑 Skipping SSH connection as per your choice.${NC}"
fi

# Elapsed time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo -e "${CYAN}⏱️ Completed in ${ELAPSED} seconds.${NC}"

# Cleanup
rm -f output.json

# Logging
{
    echo "-------------------------------------"
    echo "Instance Name: $INSTANCE_NAME"
    echo "Instance ID: $INSTANCE_ID"
    echo "Public IP: $PUBLIC_IP"
    echo "Launch Time: $LAUNCH_TIME"
    echo "Completed at: $(date)"
    echo "-------------------------------------"
} >> $LOG_FILE

