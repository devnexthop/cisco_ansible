# Ansible Scheduling Guide

## Overview

This guide explains how to schedule Ansible playbooks to run automatically at specific times or intervals.

## Scheduling Methods

### 1. Cron Jobs (Linux/macOS)

Cron is the most common method for scheduling Ansible playbooks on Linux and macOS systems.

#### Basic Cron Syntax

```bash
# Cron format: minute hour day month weekday command
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

#### Example: Schedule Daily Backup at 2 AM

**Step 1: Create a wrapper script**

```bash
# Create script
nano ~/ansible-scripts/daily-backup.sh
```

**Step 2: Add content to script**

```bash
#!/bin/bash
# Daily backup script

# Set working directory
cd /path/to/cisco_ansible

# Activate virtual environment (if using one)
source ansible-env/bin/activate

# Run playbook
ansible-playbook playbooks/switches/backup_configs.yml

# Deactivate virtual environment
deactivate
```

**Step 3: Make script executable**

```bash
chmod +x ~/ansible-scripts/daily-backup.sh
```

**Step 4: Add to crontab**

```bash
# Edit crontab
crontab -e

# Add this line (runs daily at 2:00 AM)
0 2 * * * ~/ansible-scripts/daily-backup.sh >> /var/log/ansible-backup.log 2>&1
```

#### Common Cron Examples

```bash
# Every day at 2:00 AM
0 2 * * * /path/to/script.sh

# Every hour at minute 0
0 * * * * /path/to/script.sh

# Every 15 minutes
*/15 * * * * /path/to/script.sh

# Every Monday at 3:00 AM
0 3 * * 1 /path/to/script.sh

# First day of every month at midnight
0 0 1 * * /path/to/script.sh

# Every weekday (Monday-Friday) at 6:00 AM
0 6 * * 1-5 /path/to/script.sh

# Every Sunday at 11:00 PM
0 23 * * 0 /path/to/script.sh
```

#### View Current Cron Jobs

```bash
# List all cron jobs
crontab -l

# Edit cron jobs
crontab -e

# Remove all cron jobs (be careful!)
crontab -r
```

### 2. Systemd Timers (Linux)

Systemd timers provide more advanced scheduling options on Linux systems.

#### Step 1: Create a service file

```bash
# Create service file
sudo nano /etc/systemd/system/ansible-backup.service
```

**Service file content:**
```ini
[Unit]
Description=Ansible Daily Backup
After=network.target

[Service]
Type=oneshot
User=your-username
WorkingDirectory=/path/to/cisco_ansible
ExecStart=/usr/bin/ansible-playbook playbooks/switches/backup_configs.yml
StandardOutput=journal
StandardError=journal
```

#### Step 2: Create a timer file

```bash
# Create timer file
sudo nano /etc/systemd/system/ansible-backup.timer
```

**Timer file content:**
```ini
[Unit]
Description=Run Ansible backup daily at 2 AM
Requires=ansible-backup.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
```

#### Step 3: Enable and start the timer

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable timer (starts on boot)
sudo systemctl enable ansible-backup.timer

# Start timer
sudo systemctl start ansible-backup.timer

# Check timer status
sudo systemctl status ansible-backup.timer

# List all timers
systemctl list-timers
```

### 3. Ansible Tower / AWX

Ansible Tower (commercial) and AWX (open-source) provide built-in scheduling capabilities.

#### Using AWX (Open Source)

1. **Create a Job Template** in AWX
2. **Add Schedule** to the job template
3. **Set frequency**: Daily, Weekly, Monthly, etc.
4. **Set time and timezone**
5. **Save and enable**

#### Using Ansible Tower

Similar to AWX but with enterprise features and support.

### 4. CI/CD Pipelines

Schedule playbooks using CI/CD tools like Jenkins, GitLab CI, GitHub Actions, etc.

#### GitHub Actions Example

```yaml
# .github/workflows/ansible-backup.yml
name: Daily Backup

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:  # Allow manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Ansible
        run: |
          pip install ansible
          ansible-galaxy collection install -r collections/requirements.yml
      
      - name: Run backup playbook
        run: |
          ansible-playbook playbooks/switches/backup_configs.yml
        env:
          ANSIBLE_HOST_KEY_CHECKING: False
```

## Complete Examples

### Example 1: Daily Switch Backup (Cron)

**Create script: `~/ansible-scripts/daily-switch-backup.sh`**

```bash
#!/bin/bash

# Configuration
ANSIBLE_DIR="/path/to/cisco_ansible"
LOG_FILE="/var/log/ansible/daily-backup.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Create log directory if it doesn't exist
mkdir -p /var/log/ansible

# Log start
echo "[$DATE] Starting daily switch backup..." >> "$LOG_FILE"

# Change to Ansible directory
cd "$ANSIBLE_DIR" || exit 1

# Activate virtual environment (if using one)
if [ -d "ansible-env" ]; then
    source ansible-env/bin/activate
fi

# Run backup playbook
ansible-playbook playbooks/switches/backup_configs.yml >> "$LOG_FILE" 2>&1

# Check exit status
if [ $? -eq 0 ]; then
    echo "[$DATE] Backup completed successfully" >> "$LOG_FILE"
else
    echo "[$DATE] Backup FAILED!" >> "$LOG_FILE"
    # Send email notification (optional)
    # mail -s "Ansible Backup Failed" admin@example.com < "$LOG_FILE"
fi

# Deactivate virtual environment
if [ -d "ansible-env" ]; then
    deactivate
fi
```

**Make executable:**
```bash
chmod +x ~/ansible-scripts/daily-switch-backup.sh
```

**Add to crontab:**
```bash
crontab -e

# Add this line (daily at 2:00 AM)
0 2 * * * ~/ansible-scripts/daily-switch-backup.sh
```

### Example 2: Hourly Health Check

**Create script: `~/ansible-scripts/hourly-health-check.sh`**

```bash
#!/bin/bash

ANSIBLE_DIR="/path/to/cisco_ansible"
LOG_FILE="/var/log/ansible/health-check.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p /var/log/ansible

echo "[$DATE] Starting health check..." >> "$LOG_FILE"

cd "$ANSIBLE_DIR" || exit 1

if [ -d "ansible-env" ]; then
    source ansible-env/bin/activate
fi

ansible-playbook playbooks/switches/device_health_monitor.yml >> "$LOG_FILE" 2>&1

if [ -d "ansible-env" ]; then
    deactivate
fi
```

**Add to crontab (every hour):**
```bash
0 * * * * ~/ansible-scripts/hourly-health-check.sh
```

### Example 3: Weekly Compliance Check

**Create script: `~/ansible-scripts/weekly-compliance.sh`**

```bash
#!/bin/bash

ANSIBLE_DIR="/path/to/cisco_ansible"
LOG_FILE="/var/log/ansible/compliance-check.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p /var/log/ansible

echo "[$DATE] Starting weekly compliance check..." >> "$LOG_FILE"

cd "$ANSIBLE_DIR" || exit 1

if [ -d "ansible-env" ]; then
    source ansible-env/bin/activate
fi

ansible-playbook playbooks/switches/compliance_check.yml >> "$LOG_FILE" 2>&1

if [ -d "ansible-env" ]; then
    deactivate
fi
```

**Add to crontab (every Monday at 3:00 AM):**
```bash
0 3 * * 1 ~/ansible-scripts/weekly-compliance.sh
```

## Best Practices

### 1. Use Wrapper Scripts

Always create wrapper scripts instead of calling `ansible-playbook` directly in cron:

**✅ Good:**
```bash
#!/bin/bash
cd /path/to/ansible
source venv/bin/activate
ansible-playbook playbook.yml
deactivate
```

**❌ Bad:**
```bash
# Direct in crontab - harder to debug
0 2 * * * ansible-playbook /path/to/playbook.yml
```

### 2. Logging

Always log output for troubleshooting:

```bash
# Log to file
0 2 * * * /path/to/script.sh >> /var/log/ansible.log 2>&1

# Or in script
ansible-playbook playbook.yml >> /var/log/ansible.log 2>&1
```

### 3. Error Handling

Add error checking to scripts:

```bash
#!/bin/bash
set -e  # Exit on error

cd /path/to/ansible
ansible-playbook playbook.yml

if [ $? -ne 0 ]; then
    echo "Playbook failed!" | mail -s "Ansible Error" admin@example.com
    exit 1
fi
```

### 4. Environment Variables

Set required environment variables in scripts:

```bash
#!/bin/bash
export ANSIBLE_CONFIG=/path/to/ansible.cfg
export ANSIBLE_HOST_KEY_CHECKING=False
cd /path/to/ansible
ansible-playbook playbook.yml
```

### 5. Lock Files (Prevent Overlaps)

Prevent multiple instances from running simultaneously:

```bash
#!/bin/bash
LOCK_FILE="/tmp/ansible-backup.lock"

# Check if already running
if [ -f "$LOCK_FILE" ]; then
    echo "Another instance is already running"
    exit 1
fi

# Create lock file
touch "$LOCK_FILE"

# Run playbook
ansible-playbook playbook.yml

# Remove lock file
rm "$LOCK_FILE"
```

## Troubleshooting

### Cron Job Not Running

**Check cron service:**
```bash
# Linux
sudo systemctl status cron

# macOS
sudo launchctl list | grep cron
```

**Check cron logs:**
```bash
# Linux
grep CRON /var/log/syslog

# macOS
grep cron /var/log/system.log
```

**Test script manually:**
```bash
# Run script directly to check for errors
/path/to/script.sh
```

**Common issues:**
- Script not executable: `chmod +x script.sh`
- Wrong path: Use absolute paths in cron
- Environment variables: Set them in the script
- Permissions: Check file permissions

### Systemd Timer Not Running

**Check timer status:**
```bash
sudo systemctl status ansible-backup.timer
```

**Check service logs:**
```bash
sudo journalctl -u ansible-backup.service
```

**List timer next run:**
```bash
systemctl list-timers ansible-backup.timer
```

## Quick Reference

### Cron Schedule Examples

| Schedule | Cron Expression | Description |
|----------|----------------|-------------|
| Every minute | `* * * * *` | Every minute |
| Every 5 minutes | `*/5 * * * *` | Every 5 minutes |
| Every hour | `0 * * * *` | At minute 0 of every hour |
| Daily at 2 AM | `0 2 * * *` | Every day at 2:00 AM |
| Weekly (Monday) | `0 3 * * 1` | Every Monday at 3:00 AM |
| Monthly (1st) | `0 0 1 * *` | First day of month at midnight |
| Weekdays only | `0 6 * * 1-5` | Monday-Friday at 6:00 AM |

### Common Commands

```bash
# View cron jobs
crontab -l

# Edit cron jobs
crontab -e

# Remove all cron jobs
crontab -r

# View systemd timers
systemctl list-timers

# Enable systemd timer
sudo systemctl enable timer-name.timer
sudo systemctl start timer-name.timer
```

## Summary

1. **Cron**: Best for simple scheduling on Linux/macOS
2. **Systemd Timers**: Better for Linux with advanced features
3. **Ansible Tower/AWX**: Enterprise scheduling with GUI
4. **CI/CD**: Good for integration with development workflows

**Recommended approach:**
- Use **cron** for simple, one-off schedules
- Use **wrapper scripts** with logging and error handling
- Test scripts manually before adding to cron
- Monitor logs regularly

