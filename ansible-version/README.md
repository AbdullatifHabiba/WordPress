# WordPress Infrastructure with Ansible

Simple, clean Ansible setup for deploying WordPress with MySQL, Prometheus, and Grafana on AWS EC2.

## 🚀 Quick Start

### 1. Install Requirements
```bash
pip install ansible boto3 botocore
aws configure
```

### 2. Run Deployment
```bash
# Uses dynamic inventory to fetch running EC2 instances
ansible-playbook -i inventory.py playbooks/deploy.yml
```

### 3. Access Services
- **WordPress**: http://<instance-ip>:8080
- **Grafana**: http://<instance-ip>:3000 (admin/Grafana123!)
- **Prometheus**: http://<instance-ip>:9090
- **Node Exporter**: http://<instance-ip>:9100

## ✨ Features

✅ Dynamic EC2 inventory from AWS  
✅ MySQL 8 with daily automated backups  
✅ WordPress Docker container  
✅ Prometheus + Node Exporter monitoring  
✅ Grafana dashboards  
✅ Clean, simple structure  
✅ Minimal dependencies  

## 📁 Structure

```
ansible-version/
├── inventory.py                    # Dynamic EC2 inventory (fetches running instances)
├── playbooks/
│   └── deploy.yml                 # Main deployment playbook
├── roles/
│   ├── mysql/                     # MySQL 8 with backups
│   ├── wordpress/                 # WordPress + database
│   ├── prometheus/                # Prometheus + Node Exporter
│   └── grafana/                   # Grafana dashboards
├── inventories/
│   └── group_vars/
│       └── all.yml                # Configuration variables
└── ansible.cfg                    # Ansible configuration
```

## 🔧 Configuration

Edit `inventories/group_vars/all.yml`:

```yaml
mysql_root_password: "RootPass123!"
mysql_database: wordpress
mysql_user: wordpress
mysql_password: "WordPress123!"

grafana_admin_user: admin
grafana_admin_password: "Grafana123!"
```

## 📊 What Gets Deployed

| Component | Container | Port | Access |
|-----------|-----------|------|--------|
| WordPress | wordpress | 8080 | http://<ip>:8080 |
| MySQL | wordpress-mysql | 3306 | Internal |
| Prometheus | prometheus | 9090 | http://<ip>:9090 |
| Node Exporter | node-exporter | 9100 | http://<ip>:9100 |
| Grafana | grafana | 3000 | http://<ip>:3000 |

## 🏷️ Tags

Run specific components:
```bash
ansible-playbook -i inventory.py playbooks/deploy.yml --tags mysql
ansible-playbook -i inventory.py playbooks/deploy.yml --tags wordpress
ansible-playbook -i inventory.py playbooks/deploy.yml --tags prometheus
ansible-playbook -i inventory.py playbooks/deploy.yml --tags grafana
```

## 💾 MySQL Backups

Daily backups at 2:00 AM to `/opt/mysql/backups`

```bash
ssh ubuntu@<ip>
ls -lh /opt/mysql/backups/
tail -f /var/log/mysql-backup.log
```

## 🐛 Troubleshooting

```bash
# Check containers
docker ps -a

# View logs
docker logs wordpress
docker logs grafana
docker logs prometheus

# Test inventory
ansible-inventory -i inventory.py --list
```

---

**Created**: Clean, simplified WordPress infrastructure deployment  
**Last Updated**: February 2026
- Default tags
ansible-playbook playbooks/manage_ec2.yml \
  -e "ec2_action=status" \
  -e "ec2_tags={'Environment': 'production'}"
  ## using script 
  ./scripts/manage_ec2.sh --action status --tags Environment=production
  ## using -n for name
  ./scripts/manage_ec2.sh  status -n abdu-ansible-instance
