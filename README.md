# Cisco Ansible Automation

This repository contains Ansible playbooks, roles, and configurations for automating Cisco network devices.

## Repository Structure

```
cisco_ansible/
├── ansible.cfg          # Ansible configuration file
├── .ansible-lint        # Ansible lint configuration
├── Makefile             # Makefile for common tasks
├── requirements.txt    # Python dependencies
├── collections/         # Ansible collections requirements
│   └── requirements.yml
├── inventory/           # Inventory files for devices
│   └── hosts.yml        # Main inventory file
├── playbooks/           # Ansible playbooks
│   ├── firewalls/       # Firewall-specific playbooks
│   ├── routers/         # Router-specific playbooks
│   ├── switches/        # Switch-specific playbooks
│   │   ├── backup_configs.yml
│   │   ├── find_mac_address.yml
│   │   ├── generate_inventory_csv.yml
│   │   ├── verify_spanning_tree.yml
│   │   └── verify_switch_versions.yml
│   └── testing/         # Testing and validation playbooks
│       ├── test_inventory.yml
│       ├── test_ping.yml
│       ├── test_snmp.yml
│       └── test_ssh.yml
├── roles/               # Reusable Ansible roles
├── group_vars/          # Group-specific variables
│   ├── all.yml          # Variables for all devices
│   ├── ios.yml          # Variables for IOS devices
│   ├── nxos.yml         # Variables for NX-OS devices
│   ├── asa.yml          # Variables for ASA devices
│   └── iosxe.yml        # Variables for IOS-XE devices
├── host_vars/           # Host-specific variables
├── backups/              # Configuration backups (gitignored)
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

# Generate CSV inventory report (PID and Software Version)
ansible-playbook playbooks/switches/generate_inventory_csv.yml
# Output: reports/switch_inventory_<timestamp>.csv
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

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Cisco Ansible Collection](https://galaxy.ansible.com/cisco)
- [Network Automation with Ansible](https://docs.ansible.com/ansible/latest/network/)

