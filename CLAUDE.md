# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Cisco network automation repository using Ansible. It manages Cisco IOS, IOS-XE, NX-OS, and ASA devices through playbooks organized by device type (switches, routers, firewalls).

## Common Commands

```bash
# Install dependencies
make install              # Python dependencies
make install-collections  # Ansible collections (cisco.ios, cisco.nxos, cisco.asa, ansible.netcommon)

# Linting
make lint                 # Run ansible-lint on playbooks/

# Testing
make test                 # Runs test_inventory.yml and test_ping.yml
ansible-playbook playbooks/testing/test_ssh.yml    # Test SSH connectivity
ansible-playbook playbooks/testing/test_snmp.yml   # Test SNMP connectivity

# Run a specific playbook
ansible-playbook playbooks/switches/backup_configs.yml
ansible-playbook playbooks/switches/find_mac_address.yml --extra-vars 'mac_address=xxxx.xxxx.xxxx'

# Ad-hoc commands
ansible ios -m cisco.ios.ios_command -a "commands='show version'"
ansible all -m ping
```

## Architecture

### Inventory Structure
- `inventory/hosts.yml` - Main inventory with device groups: `ios`, `nxos`, `asa`, `iosxe`
- Each host requires: `ansible_host` (IP), `ansible_network_os` (platform)
- Credentials use Ansible Vault (vault password file: `~/.ansible_vault_pass`)

### Variables Hierarchy
- `group_vars/all.yml` - Global settings (connection type: `network_cli`, timeouts, NTP/syslog servers)
- `group_vars/{ios,nxos,asa,iosxe}.yml` - Platform-specific settings (become method, network_os)
- `host_vars/` - Per-device overrides

### Playbook Organization
- `playbooks/switches/` - Switch operations (backup, compliance, health monitoring, MAC tracking)
- `playbooks/routers/` - Router configuration
- `playbooks/firewalls/` - ASA firewall management
- `playbooks/testing/` - Connectivity and inventory validation

### Connection Settings (ansible.cfg)
- Uses `network_cli` connection with paramiko SSH
- `strategy = free` for parallel execution
- `forks = 10` for concurrent connections
- Persistent connection timeouts configured for network devices

## Key Patterns

### Network Module Usage
Playbooks use Cisco collection modules:
- `cisco.ios.ios_command` - Execute show commands
- `cisco.ios.ios_config` - Configuration changes
- `cisco.ios.ios_facts` - Gather device facts

### Common Playbook Structure
```yaml
- name: Playbook Name
  hosts: ios  # or switches, nxos, etc.
  gather_facts: no  # Always disabled for network devices

  tasks:
    - name: Run command
      cisco.ios.ios_command:
        commands:
          - show version
      register: result
```

### Output Locations
- `backups/` - Configuration backups (gitignored)
- `reports/` - Generated reports (gitignored)

### Documentation
- `docs/` - Detailed guides (tips, modules, scheduling, troubleshooting)
