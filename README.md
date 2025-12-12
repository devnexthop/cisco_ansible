# Cisco Ansible Automation

This repository contains Ansible playbooks, roles, and configurations for automating Cisco network devices.

## Repository Structure

```
cisco_ansible/
├── ansible.cfg          # Ansible configuration
├── Makefile             # Common tasks (install, lint, test)
├── inventory/hosts.yml  # Device inventory
├── playbooks/           # Ansible playbooks
│   ├── switches/        # Switch playbooks (backup, compliance, health, etc.)
│   ├── routers/         # Router playbooks
│   ├── firewalls/       # Firewall playbooks
│   └── testing/         # Connectivity tests
├── group_vars/          # Variables by device type (ios, nxos, asa, iosxe)
├── host_vars/           # Per-device variables
├── roles/               # Reusable roles
├── collections/         # Ansible Galaxy requirements
├── docs/                # Documentation guides
├── backups/             # Config backups (gitignored)
└── reports/             # Generated reports (gitignored)
```

## Prerequisites

- Ansible 2.9 or later
- Python 3.6 or later
- Required Ansible collections:
  - `cisco.ios`
  - `cisco.nxos`
  - `cisco.asa`
  - `ansible.netcommon`

## Installation

### Quick Setup (using Makefile):
```bash
make install              # Install Python dependencies
make install-collections  # Install Ansible collections
```

### Manual Installation:

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Install required collections:
```bash
ansible-galaxy collection install -r collections/requirements.yml
```

Or install individually:
```bash
ansible-galaxy collection install cisco.ios
ansible-galaxy collection install cisco.nxos
ansible-galaxy collection install cisco.asa
ansible-galaxy collection install ansible.netcommon
```

## Configuration

1. Update the inventory file (`inventory/hosts.yml`) with your device IP addresses and credentials.

2. Configure variables in `group_vars/` files according to your environment.

3. For secure credential storage, use Ansible Vault:
```bash
ansible-vault encrypt_string 'your_password' --name 'ansible_password'
```

## Usage

### Run a playbook:

**Switches:**
```bash
# Backup switch configurations
ansible-playbook playbooks/switches/backup_configs.yml

# Find MAC address on switches
ansible-playbook playbooks/switches/find_mac_address.yml --extra-vars 'mac_address=xxxx.xxxx.xxxx'

# Verify spanning tree configuration
ansible-playbook playbooks/switches/verify_spanning_tree.yml

# Verify switch versions
ansible-playbook playbooks/switches/verify_switch_versions.yml

# Generate inventory report (PID and Software Version)
ansible-playbook playbooks/switches/generate_inventory.yml

# Check configuration drift (running vs startup)
ansible-playbook playbooks/switches/check_config_drift.yml

# Port utilization report
ansible-playbook playbooks/switches/port_utilization_report.yml

# Network topology discovery (CDP/LLDP)
ansible-playbook playbooks/switches/network_topology_discovery.yml

# Compliance check (security policies)
ansible-playbook playbooks/switches/compliance_check.yml

# Device health monitoring (CPU, memory, temperature)
ansible-playbook playbooks/switches/device_health_monitor.yml

# MAC address tracking
ansible-playbook playbooks/switches/mac_address_tracking.yml
# Optional: Search for specific MAC
ansible-playbook playbooks/switches/mac_address_tracking.yml --extra-vars 'mac_address=xxxx.xxxx.xxxx'
```

**Routers:**
```bash
# Configure IOS-XE routers
ansible-playbook playbooks/routers/iosxe-router-config.yml
```

**Firewalls:**
```bash
# Configure ASA firewalls
ansible-playbook playbooks/firewalls/asa-config.yml
```

**Testing:**
```bash
# Check inventory information
ansible-playbook playbooks/testing/test_inventory.yml

# Test ping connectivity
ansible-playbook playbooks/testing/test_ping.yml

# Test SNMP connectivity
ansible-playbook playbooks/testing/test_snmp.yml

# Test SSH connectivity
ansible-playbook playbooks/testing/test_ssh.yml
```

### Test connectivity:
```bash
ansible all -m ping
```

### Run ad-hoc commands:
```bash
ansible ios -m cisco.ios.ios_command -a "commands='show version'"
```

### Using Makefile:
```bash
make lint              # Run ansible-lint on playbooks
make test             # Run test playbooks
make inventory-csv    # Generate switch inventory CSV report
make clean            # Remove generated files (backups, reports)
```

## Supported Platforms

- Cisco IOS
- Cisco IOS-XE
- Cisco NX-OS
- Cisco ASA

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is open source and available for use.

## Documentation

Detailed guides are available in the `docs/` folder:

- [Ansible Tips](docs/ANSIBLE_TIPS.md) - Ad-hoc commands, playbook flags, host patterns
- [Cisco IOS Modules](docs/CISCO_IOS_MODULES.md) - Module reference and examples
- [Inventory Management](docs/INVENTORY_MANAGEMENT.md) - Adding/removing devices
- [Scheduling](docs/ANSIBLE_SCHEDULING.md) - Cron, systemd, CI/CD scheduling
- [Performance](docs/PERFORMANCE.md) - Optimization tips
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Quick Start](docs/QUICK_START.md) - Creating new playbooks
- [File Permissions](docs/PLAYBOOK_FILE_PERMISSIONS.md) - chmod/chown playbooks
- [IPAM API Testing](docs/IPAM_API_TESTING.md) - curl commands for IPAM systems

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Cisco Ansible Collection](https://galaxy.ansible.com/cisco)
- [Network Automation with Ansible](https://docs.ansible.com/ansible/latest/network/)

