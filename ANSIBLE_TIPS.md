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
# Run on all switches EXCEPT one device
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches:!switch-01

# Exclude multiple devices
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches:!switch-01:!switch-02

# Run on all switches except devices matching a pattern
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches:!*WAREHOUSE*
```

### Complex Patterns
```bash
# Run on switches in site1 but exclude one device
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit site1_switches:!switch-01

# Run on multiple groups but exclude specific hosts
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches,routers:!problematic-device

# Run on all except maintenance devices
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit all:!maintenance
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

# All switches except those in maintenance group
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches:!maintenance
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

# All switches in site1 except switch-02
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit site1_switches:!switch-02

# All switches except site1
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches:!site1_switches
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
# Run on all devices except the one being maintained
ansible-playbook playbooks/switches/backup_configs.yml --limit switches:!switch-under-maintenance
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
# Run on all switches in site1 except one
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit site1_switches:!switch-01
```

### Exclude Problem Devices
```bash
# Run on all switches except known problematic ones
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switches:!problem-device-1:!problem-device-2
```

