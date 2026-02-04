# EC2 Management Role

Role to manage EC2 instances with support for start, stop, terminate, and status operations. Instances can be filtered by tags.

## Features

- ✅ **Start** EC2 instances matching tags
- ✅ **Stop** EC2 instances matching tags
- ✅ **Terminate** EC2 instances matching tags
- ✅ **Query** EC2 instances status by tags
- ✅ Tag-based filtering (multiple tags supported)
- ✅ Wait for state transitions
- ✅ Detailed output with instance information

## Requirements

- `amazon.aws` collection (>= 2.0)
- Valid AWS credentials
- EC2 instances with proper tags

## Variables

### Required Variables

```yaml
# AWS credentials
aws_access_key: "YOUR_AWS_ACCESS_KEY"
aws_secret_key: "YOUR_AWS_SECRET_KEY"

# AWS region
aws_region: us-east-1

# Action to perform: start, stop, terminate, status
ec2_action: status

# Tags to filter instances
ec2_tags:
  Environment: production
  Project: wordpress
```

### Optional Variables

```yaml
# Wait timeout for state transitions (seconds)
wait_timeout: 300

# Enable verbose output
verbose: false
```

## Usage Examples

### 1. Query Instance Status by Tags

```bash
ansible-playbook -i inventory.ini site.yml \
  -e "ec2_action=status" \
  -e "ec2_tags={'Environment': 'production', 'Project': 'wordpress'}"
```

### Playbook Example:
```yaml
- name: Check WordPress Instances
  hosts: localhost
  connection: local
  gather_facts: false
  roles:
    - ec2_manage
  vars:
    ec2_action: status
    ec2_tags:
      Environment: production
      Project: wordpress
```

### 2. Start Stopped Instances

```bash
ansible-playbook manage_ec2.yml \
  -e "ec2_action=start" \
  -e "ec2_tags={'Environment': 'production'}"
```

### 3. Stop Running Instances

```bash
ansible-playbook manage_ec2.yml \
  -e "ec2_action=stop" \
  -e "ec2_tags={'Project': 'wordpress'}"
```

### 4. Terminate Instances (Destructive)

```bash
ansible-playbook manage_ec2.yml \
  -e "ec2_action=terminate" \
  -e "ec2_tags={'Environment': 'staging'}" \
  --ask-confirm
```

---

## Complete Playbook Example

Create `playbooks/manage_ec2.yml`:

```yaml
---
- name: EC2 Instance Management
  hosts: localhost
  connection: local
  gather_facts: false
  vars_files:
    - vars.yml
  
  vars:
    # Override these from command line with -e
    ec2_action: status
    ec2_tags:
      Environment: production
  
  roles:
    - ec2_manage
```

### Run Commands:

```bash
# Check status of all production instances
ansible-playbook playbooks/manage_ec2.yml

# Start all production instances
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=start"

# Stop only WordPress project instances
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=stop" \
  -e "ec2_tags={'Project': 'wordpress'}"

# Terminate staging instances
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=terminate" \
  -e "ec2_tags={'Environment': 'staging'}"
```

---

## Tag Filtering

### Single Tag Filter

```bash
-e "ec2_tags={'Environment': 'production'}"
```

Finds all instances with tag `Environment=production`

### Multiple Tag Filter (AND condition)

```bash
-e "ec2_tags={'Environment': 'production', 'Project': 'wordpress'}"
```

Finds instances with BOTH:
- `Environment=production` AND
- `Project=wordpress`

### Common Tags to Use

```yaml
# Environment-based
Environment: production
Environment: staging
Environment: development

# Project-based
Project: wordpress
Project: database
Project: monitoring

# Name-based
Name: wordpress-instance
Name: mysql-backup

# Custom
Application: blog
Owner: devops
CostCenter: engineering
```

---

## Output Examples

### Status Query Output

```
Found 2 instance(s) matching tags:
  - Environment: production
  - Project: wordpress

Instances:
  - ID: i-0123456789abcdef0
    State: running
    Type: t2.micro
    Tags: {Name: wordpress-1, Environment: production, Project: wordpress}
    Public IP: 54.242.247.58

  - ID: i-0abcdef0123456789
    State: stopped
    Type: t2.small
    Tags: {Name: wordpress-2, Environment: production, Project: wordpress}
    Public IP: N/A
```

### Start Output

```
Started 1 instance(s)
  - i-0123456789abcdef0: running
```

### Stop Output

```
Stopped 2 instance(s)
  - i-0123456789abcdef0: stopped
  - i-0abcdef0123456789: stopped
```

### Terminate Output

```
Terminated 1 instance(s)
  - i-0abcdef0123456789: terminated
```

---

## Advanced Usage

### Bulk Operations

Stop all development instances:
```bash
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=stop" \
  -e "ec2_tags={'Environment': 'development'}"
```

### With Timeout Adjustment

```bash
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=start" \
  -e "ec2_tags={'Environment': 'production'}" \
  -e "wait_timeout=600"
```

### Verbose Output

```bash
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=status" \
  -e "verbose=true"
```

---

## Troubleshooting

### No instances found

**Problem**: Role reports "No EC2 instances found"

**Solutions**:
1. Check tags match exactly (case-sensitive)
2. Verify AWS credentials in vars.yml
3. Ensure instances have the tags specified
4. Check AWS region is correct

### Connection timeout

**Problem**: "Task failed: timed out waiting for instance transition"

**Solution**: Increase wait_timeout:
```bash
-e "wait_timeout=600"
```

### Permission denied

**Problem**: AWS API returns permission error

**Solutions**:
1. Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
2. Ensure IAM user has EC2 permissions:
   - `ec2:DescribeInstances`
   - `ec2:StartInstances`
   - `ec2:StopInstances`
   - `ec2:TerminateInstances`

---

## Notes

- All operations are performed on localhost (no remote host needed)
- Instances must have matching tags to be affected
- State transitions may take 30-60 seconds
- Terminated instances cannot be restarted
- Role is idempotent (safe to run multiple times)

---

## Best Practices

1. **Always test with status first**
   ```bash
   ansible-playbook manage_ec2.yml -e "ec2_action=status"
   ```

2. **Use meaningful tags**
   - Environment (dev/staging/prod)
   - Project name
   - Owner
   - Cost center

3. **Backup before terminating**
   - Create snapshots of volumes
   - Back up data
   - Document configuration

4. **Monitor state changes**
   - Use CloudWatch
   - Set up alerts
   - Track downtime

5. **Schedule operations**
   - Use cron for automated start/stop
   - Coordinate with team
   - Document maintenance windows
