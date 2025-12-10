# Ansible Tips & Tricks

## Running Playbooks on Specific Hosts

### Include Specific Hosts
```bash
# Run on single host
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switch-01

# Run on multiple specific hosts
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switch-01,switch-02,switch-03

# Run on all hosts in a group
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches
```

### Exclude Specific Hosts
```bash
# Run on all switches EXCEPT one device (QUOTE THE LIMIT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches:!switch-01"

# Exclude multiple devices (QUOTE THE LIMIT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches:!switch-01:!switch-02"

# Run on all switches except devices matching a pattern (QUOTE THE LIMIT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches:!*WAREHOUSE*"

# IMPORTANT: Always quote exclusion patterns to prevent bash history expansion errors!
# Without quotes: bash interprets ! as history expansion → "event not found" error
# With quotes: Ansible receives the pattern correctly
```

### Complex Patterns
```bash
# Run on switches in site1 but exclude one device (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "site1_switches:!switch-01"

# Run on multiple groups but exclude specific hosts (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches,routers:!problematic-device"

# Run on all except maintenance devices (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "all:!maintenance"
```

## Pattern Examples

### Wildcards
```bash
# All switches starting with "SSA"
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit SSA*

# All switches in site 100
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit *100*
```

### Multiple Patterns
```bash
# Switches in site1 OR site2
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit site1_switches:site2_switches

# All switches except those in maintenance group (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches:!maintenance"
```

## Inventory Group Examples

If your inventory looks like this:
```yaml
all:
  children:
    switches:
      children:
        site1_switches:
          hosts:
            switch-01:
            switch-02:
            switch-03:
        site2_switches:
          hosts:
            switch-04:
            switch-05:
```

You can use:
```bash
# All switches in site1
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit site1_switches

# All switches in site1 except switch-02 (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "site1_switches:!switch-02"

# All switches except site1 (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches:!site1_switches"
```

## Useful Flags

### Dry Run (Check Mode)
```bash
# See what would change without making changes
ansible-playbook playbooks/switches/backup_configs.yml --check
```

### Step Through Tasks
```bash
# Confirm each task before running
ansible-playbook playbooks/switches/network_topology_discovery.yml --step
```

### Run Specific Tags
```bash
# Only run tasks with specific tags
ansible-playbook playbooks/switches/network_topology_discovery.yml --tags discovery

# Skip specific tags
ansible-playbook playbooks/switches/network_topology_discovery.yml --skip-tags slow
```

### Verbose Output
```bash
# More detailed output
ansible-playbook playbooks/switches/network_topology_discovery.yml -v   # Verbose
ansible-playbook playbooks/switches/network_topology_discovery.yml -vv  # More verbose
ansible-playbook playbooks/switches/network_topology_discovery.yml -vvv # Most verbose
```

## Common Use Cases

### Maintenance Window
```bash
# Run on all devices except the one being maintained (QUOTE IT!)
ansible-playbook playbooks/switches/backup_configs.yml --limit "switches:!switch-under-maintenance"
```

### Testing on One Device First
```bash
# Test on one device
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switch-01

# If successful, run on all
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches
```

### Site-Specific Operations
```bash
# Run on all switches in site1 except one (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "site1_switches:!switch-01"
```

### Exclude Problem Devices
```bash
# Run on all switches except known problematic ones (QUOTE IT!)
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit "switches:!problem-device-1:!problem-device-2"
```

## ⚠️ IMPORTANT: Bash History Expansion Issue

### The Problem
When using `!` in `--limit` patterns, bash interprets it as history expansion, causing errors:
```bash
# ❌ WRONG - This will fail with "event not found" error
ansible-playbook switches/verify_spanning_tree.yml --limit switches:!SSAINT234_PNL_RM_1
# Error: -bash: !SSAINT234_PNL_RM_1: event not found
```

### The Solution
**Always quote exclusion patterns** to prevent bash from interpreting `!`:
```bash
# ✅ CORRECT - Quote the entire limit pattern
ansible-playbook switches/verify_spanning_tree.yml --limit "switches:!SSAINT234_PNL_RM_1"

# ✅ Also works with single quotes
ansible-playbook switches/verify_spanning_tree.yml --limit 'switches:!SSAINT234_PNL_RM_1'
```

### Alternative Solutions
```bash
# Option 1: Disable history expansion temporarily
set +H
ansible-playbook switches/verify_spanning_tree.yml --limit switches:!SSAINT234_PNL_RM_1
set -H

# Option 2: Escape the exclamation mark
ansible-playbook switches/verify_spanning_tree.yml --limit switches:\!SSAINT234_PNL_RM_1

# Option 3: Use quotes (RECOMMENDED - Easiest!)
ansible-playbook switches/verify_spanning_tree.yml --limit "switches:!SSAINT234_PNL_RM_1"
```

## Using Ansible Modules Directly (Ad-Hoc Commands)

### Basic Syntax
```bash
ansible <host_pattern> -m <module_name> -a "<module_arguments>"
```

### Ping Module
```bash
# Ping all switches (tests connectivity)
ansible switches -m ping

# Ping specific switch
ansible switch-01 -m ping

# Ping with limit
ansible all -m ping --limit switches
```

### Cisco IOS Command Module (`cisco.ios.ios_command`)
```bash
# Run single command
ansible switches -m cisco.ios.ios_command -a "commands='show version'"

# Run multiple commands
ansible switches -m cisco.ios.ios_command -a "commands='show version','show inventory'"

# Run on specific host
ansible switch-01 -m cisco.ios.ios_command -a "commands='show running-config'"

# Run with limit/exclude
ansible switches -m cisco.ios.ios_command -a "commands='show version'" --limit switches:!switch-01
```

### Cisco IOS Config Module (`cisco.ios.ios_config`)
```bash
# Show running config
ansible switches -m cisco.ios.ios_config -a "commands='show running-config'"

# Apply configuration lines
ansible switches -m cisco.ios.ios_config -a "lines='hostname NEW_HOSTNAME'"

# Backup running config
ansible switches -m cisco.ios.ios_config -a "backup=yes"
```

### Cisco IOS Facts Module (`cisco.ios.ios_facts`)
```bash
# Gather facts from switches
ansible switches -m cisco.ios.ios_facts

# Get facts from specific switch
ansible switch-01 -m cisco.ios.ios_facts
```

### Common Cisco IOS Commands Examples
```bash
# Show version
ansible switches -m cisco.ios.ios_command -a "commands='show version'"

# Show inventory
ansible switches -m cisco.ios.ios_command -a "commands='show inventory'"

# Show MAC address table
ansible switches -m cisco.ios.ios_command -a "commands='show mac address-table'"

# Show CDP neighbors
ansible switches -m cisco.ios.ios_command -a "commands='show cdp neighbors'"

# Show interface status
ansible switches -m cisco.ios.ios_command -a "commands='show ip interface brief'"

# Show spanning tree
ansible switches -m cisco.ios.ios_command -a "commands='show spanning-tree summary'"

# Disable paging and show config
ansible switches -m cisco.ios.ios_command -a "commands='terminal length 0','show running-config'"
```

### Useful Flags for Ad-Hoc Commands
```bash
# Verbose output
ansible switches -m cisco.ios.ios_command -a "commands='show version'" -v
ansible switches -m cisco.ios.ios_command -a "commands='show version'" -vv
ansible switches -m cisco.ios.ios_command -a "commands='show version'" -vvv

# Limit to specific hosts
ansible switches -m cisco.ios.ios_command -a "commands='show version'" --limit switch-01

# Exclude hosts (QUOTE IT!)
ansible switches -m cisco.ios.ios_command -a "commands='show version'" --limit "switches:!switch-01"

# One-line output (for scripts)
ansible switches -m cisco.ios.ios_command -a "commands='show version'" --one-line

# Save output to file
ansible switches -m cisco.ios.ios_command -a "commands='show version'" > output.txt
```

### Real-World Examples
```bash
# Quick connectivity test
ansible switches -m ping

# Check all switch versions
ansible switches -m cisco.ios.ios_command -a "commands='show version'"

# Backup configs from all switches
ansible switches -m cisco.ios.ios_config -a "backup=yes backup_options={'filename': 'backup.cfg'}"

# Find MAC address on all switches
ansible switches -m cisco.ios.ios_command -a "commands='show mac address-table address aa:bb:cc:dd:ee:ff'"

# Check CDP neighbors on all switches
ansible switches -m cisco.ios.ios_command -a "commands='terminal length 0','show cdp neighbors'"

# Get interface status from specific switch
ansible switch-01 -m cisco.ios.ios_command -a "commands='show ip interface brief'"

# Run on all switches except one (QUOTE IT!)
ansible switches -m cisco.ios.ios_command -a "commands='show version'" --limit "switches:!SSA100240_WAREHOUSE"
```

### Module Documentation
```bash
# Get help for a module
ansible-doc cisco.ios.ios_command
ansible-doc cisco.ios.ios_config
ansible-doc ping

# List all available modules
ansible-doc -l

# List Cisco modules
ansible-doc -l | grep cisco
```


