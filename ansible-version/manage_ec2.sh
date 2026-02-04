#!/bin/bash
# Quick EC2 Management Commands

PROJECT_DIR="/mnt/data/Courses/aws/aws-project/ansible-version"
PLAYBOOK="$PROJECT_DIR/playbooks/manage_ec2.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    cat << EOF
EC2 Management Helper Script

Usage: $0 <action> [options]

Actions:
  status              Query instance status (default)
  start               Start instances
  stop                Stop instances
  terminate           Terminate instances (DESTRUCTIVE)

Options:
  -t, --tags          Tags as YAML: "Environment: production" or "Environment: production, Project: wordpress"
  -n, --name          EC2 instance Name: "web-server" or "abdu-ansible-instance"
  -h, --help          Show this help message
  -v, --verbose       Enable verbose output

Examples:

  # Check status by instance name
  $0 status -n "abdu-ansible-instance"

  # Check status of production instances
  $0 status -t "Environment: production"

  # Start all WordPress instances
  $0 start -t "Project: wordpress"

  # Stop staging instances by name
  $0 stop -n "staging-web-server"

  # Multiple tags (AND condition)
  $0 status -t "Environment: production, Project: wordpress"

  # Terminate with confirmation
  $0 terminate -t "Environment: development"

EOF
    exit 1
}

# Default values
ACTION="status"
TAGS=""
NAME=""
VERBOSE="false"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        status|start|stop|terminate)
            ACTION="$1"
            shift
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -n|--name)
            NAME="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Confirm termination
if [ "$ACTION" = "terminate" ]; then
    echo -e "${YELLOW}WARNING: This will TERMINATE instances!${NC}"
    if [ -n "$NAME" ]; then
        echo "Instance Name: $NAME"
    fi
    if [ -n "$TAGS" ]; then
        echo "Tags: $TAGS"
    fi
    read -p "Are you sure? Type 'yes' to confirm: " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${RED}Aborted${NC}"
        exit 1
    fi
fi

# Run the playbook
echo -e "${GREEN}Running EC2 ${ACTION}...${NC}"
cd "$PROJECT_DIR" || exit 1

# Build ansible command
CMD="ansible-playbook playbooks/manage_ec2.yml"
CMD="$CMD -e \"ec2_action=$ACTION\""

if [ -n "$TAGS" ]; then
    CMD="$CMD -e \"ec2_tags={$TAGS}\""
fi

if [ -n "$NAME" ]; then
    CMD="$CMD -e \"ec2_name=$NAME\""
fi

CMD="$CMD -e \"verbose=$VERBOSE\""

# Execute the command
eval "$CMD"

# Check result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Action completed successfully${NC}"
else
    echo -e "${RED}✗ Action failed${NC}"
    exit 1
fi
