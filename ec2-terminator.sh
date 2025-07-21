#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get default AWS region
DEFAULT_REGION=$(aws configure get region)

echo -e "${CYAN}------------------------------------------"
echo "    EC2 Instance Terminator Script"
echo -e "------------------------------------------${NC}"

echo -e "${YELLOW}🔍 Fetching all running EC2 instances in $DEFAULT_REGION...${NC}"

# Get list of running instances
INSTANCES=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,Tags[?Key==`Name`] | [0].Value,State.Name]' \
  --output text \
  --region "$DEFAULT_REGION")

if [[ -z "$INSTANCES" ]]; then
  echo -e "${RED}❌ No running instances found in region $DEFAULT_REGION.${NC}"
  exit 0
fi

# Show list
echo -e "${CYAN}\n🟢 Running Instances:\n"
printf "${YELLOW}%-20s %-15s %-30s %-10s${NC}\n" "Instance ID" "Public IP" "Name" "State"
echo "--------------------------------------------------------------------------------------"
echo "$INSTANCES" | while read -r ID IP NAME STATE; do
    printf "%-20s %-15s %-30s %-10s\n" "$ID" "$IP" "$NAME" "$STATE"
done

echo ""

# Ask for the instance ID to terminate
read -p "Enter the Instance ID you want to terminate: " INSTANCE_ID

if [[ -z "$INSTANCE_ID" ]]; then
    echo -e "${RED}❌ Instance ID is required.${NC}"
    exit 1
fi

# Get details for confirmation
INSTANCE_DESC=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$DEFAULT_REGION" 2>/dev/null)

if [[ -z "$INSTANCE_DESC" ]]; then
    echo -e "${RED}❌ Instance ID not found or inaccessible.${NC}"
    exit 1
fi

# Extract info
INSTANCE_NAME=$(echo "$INSTANCE_DESC" | jq -r '.Reservations[0].Instances[0].Tags[] | select(.Key=="Name") | .Value')
STATE=$(echo "$INSTANCE_DESC" | jq -r '.Reservations[0].Instances[0].State.Name')
PUBLIC_IP=$(echo "$INSTANCE_DESC" | jq -r '.Reservations[0].Instances[0].PublicIpAddress')

echo -e "${CYAN}\n📋 Selected Instance Info:"
echo "🆔 ID: $INSTANCE_ID"
echo "🏷️ Name: $INSTANCE_NAME"
echo "📍 State: $STATE"
echo "🌐 IP: $PUBLIC_IP${NC}"

# Confirm termination
read -p "❗ Are you sure you want to TERMINATE this instance? (yes/no): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️ Terminating instance $INSTANCE_ID...${NC}"
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$DEFAULT_REGION"
    echo -e "${YELLOW}⏳ Waiting for termination to complete...${NC}"
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$DEFAULT_REGION"
    echo -e "${GREEN}✅ Instance $INSTANCE_ID has been successfully terminated.${NC}"
else
    echo -e "${CYAN}👍 Instance left running. No action taken.${NC}"
fi

