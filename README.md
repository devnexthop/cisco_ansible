# Cisco Ansible Automation

This repository contains Ansible playbooks, roles, and configurations for automating Cisco network devices.

## Repository Structure

```
cisco_ansible/
├── ansible.cfg          # Ansible configuration file
├── inventory/           # Inventory files for devices
│   └── hosts.yml        # Main inventory file
├── playbooks/           # Ansible playbooks
│   ├── firewalls/       # Firewall-specific playbooks
│   │   └── asa-config.yml
│   ├── routers/         # Router-specific playbooks
│   │   └── iosxe-router-config.yml
│   ├── switches/        # Switch-specific playbooks
│   │   ├── ios-switch-config.yml
│   │   └── nxos-switch-config.yml
│   └── testing/         # Testing and validation playbooks
│       ├── connectivity-test.yml
│       └── device-info.yml
├── roles/               # Reusable Ansible roles
├── group_vars/          # Group-specific variables
│   ├── all.yml          # Variables for all devices
│   ├── ios.yml          # Variables for IOS devices
│   ├── nxos.yml         # Variables for NX-OS devices
│   ├── asa.yml          # Variables for ASA devices
│   └── iosxe.yml        # Variables for IOS-XE devices
└── host_vars/           # Host-specific variables
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

1. Install Ansible:
```bash
pip install ansible
```

2. Install required collections:
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
# Configure IOS switches
ansible-playbook playbooks/switches/ios-switch-config.yml

# Configure NX-OS switches
ansible-playbook playbooks/switches/nxos-switch-config.yml
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
# Test connectivity to all devices
ansible-playbook playbooks/testing/connectivity-test.yml

# Gather device information
ansible-playbook playbooks/testing/device-info.yml
```

### Test connectivity:
```bash
ansible all -m ping
```

### Run ad-hoc commands:
```bash
ansible ios -m cisco.ios.ios_command -a "commands='show version'"
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

