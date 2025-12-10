# Ansible Inventory Management Guide

## Overview

This guide explains how to add and remove devices from your Ansible inventory file (`inventory/hosts.yml`).

## Inventory File Location

The main inventory file is located at: `inventory/hosts.yml`

## Adding Devices

### Basic Structure

The inventory file uses YAML format with a hierarchical structure:

```yaml
all:
  children:
    <group_name>:
      hosts:
        <device_name>:
          ansible_host: <ip_address>
          ansible_network_os: <os_type>
```

### Adding a Single Device

#### Example: Add an IOS Switch

**Before:**
```yaml
ios:
  hosts:
    ios-switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
```

**After (adding ios-switch-03):**
```yaml
ios:
  hosts:
    ios-switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
    ios-switch-02:
      ansible_host: 192.168.1.11
      ansible_network_os: ios
    ios-switch-03:                    # ← NEW DEVICE
      ansible_host: 192.168.1.12      # ← IP ADDRESS
      ansible_network_os: ios         # ← OS TYPE
```

### Adding Multiple Devices

```yaml
ios:
  hosts:
    ios-switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
    ios-switch-02:
      ansible_host: 192.168.1.11
      ansible_network_os: ios
    ios-switch-03:                    # ← NEW
      ansible_host: 192.168.1.12
      ansible_network_os: ios
    ios-switch-04:                    # ← NEW
      ansible_host: 192.168.1.13
      ansible_network_os: ios
```

### Adding Different Device Types

#### IOS Switch
```yaml
ios:
  hosts:
    switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
```

#### IOS-XE Router
```yaml
iosxe:
  hosts:
    router-01:
      ansible_host: 192.168.1.20
      ansible_network_os: iosxe
```

#### NX-OS Switch
```yaml
nxos:
  hosts:
    nxos-switch-01:
      ansible_host: 192.168.1.30
      ansible_network_os: nxos
```

#### ASA Firewall
```yaml
asa:
  hosts:
    asa-firewall-01:
      ansible_host: 192.168.1.40
      ansible_network_os: asa
```

### Adding Devices with Custom Groups

You can organize devices by location, function, or any other criteria:

```yaml
all:
  children:
    switches:
      children:
        site1_switches:
          hosts:
            site1-switch-01:
              ansible_host: 192.168.1.10
              ansible_network_os: ios
            site1-switch-02:
              ansible_host: 192.168.1.11
              ansible_network_os: ios
        site2_switches:
          hosts:
            site2-switch-01:
              ansible_host: 192.168.2.10
              ansible_network_os: ios
            site2-switch-02:
              ansible_host: 192.168.2.11
              ansible_network_os: ios
```

### Adding Devices with Host-Specific Variables

For devices that need unique settings:

```yaml
ios:
  hosts:
    switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
      ansible_user: admin
      ansible_password: !vault |
        $ANSIBLE_VAULT;1.1;AES256
      # Custom variables
      site: "datacenter-1"
      role: "core-switch"
```

Or use `host_vars/` directory:
```bash
# Create host-specific variable file
mkdir -p host_vars
cat > host_vars/switch-01.yml <<EOF
---
ansible_user: admin
ansible_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
site: "datacenter-1"
role: "core-switch"
EOF
```

## Removing Devices

### Remove a Single Device

Simply delete the device entry from the inventory file:

**Before:**
```yaml
ios:
  hosts:
    ios-switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
    ios-switch-02:
      ansible_host: 192.168.1.11
      ansible_network_os: ios
    ios-switch-03:
      ansible_host: 192.168.1.12
      ansible_network_os: ios
```

**After (removed ios-switch-02):**
```yaml
ios:
  hosts:
    ios-switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
    # ios-switch-02 removed
    ios-switch-03:
      ansible_host: 192.168.1.12
      ansible_network_os: ios
```

### Remove Multiple Devices

Delete the entries for all devices you want to remove:

```yaml
ios:
  hosts:
    ios-switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
    # ios-switch-02 removed
    # ios-switch-03 removed
    ios-switch-04:
      ansible_host: 192.168.1.13
      ansible_network_os: ios
```

### Remove an Entire Group

If you want to remove all devices in a group:

**Before:**
```yaml
all:
  children:
    ios:
      hosts:
        ios-switch-01:
          ansible_host: 192.168.1.10
          ansible_network_os: ios
    nxos:
      hosts:
        nxos-switch-01:
          ansible_host: 192.168.1.20
          ansible_network_os: nxos
```

**After (removed nxos group):**
```yaml
all:
  children:
    ios:
      hosts:
        ios-switch-01:
          ansible_host: 192.168.1.10
          ansible_network_os: ios
    # nxos group removed
```

### Clean Up Host Variables

After removing a device, also remove its host-specific variables:

```bash
# Remove host variable file if it exists
rm host_vars/switch-01.yml
```

## Verifying Inventory Changes

### List All Devices
```bash
ansible-inventory --list
```

### List Devices in a Group
```bash
ansible-inventory --list --limit switches
```

### Test Connectivity
```bash
# Test all devices
ansible all -m ping

# Test specific group
ansible switches -m ping

# Test specific device
ansible switch-01 -m ping
```

### Validate Inventory Syntax
```bash
# Check for syntax errors
ansible-inventory --list > /dev/null

# Or use ansible-playbook with --check
ansible-playbook playbooks/testing/test_inventory.yml --check
```

## Complete Example: Adding a New Switch

### Step 1: Edit inventory/hosts.yml

```yaml
all:
  children:
    switches:
      hosts:
        switch-01:
          ansible_host: 192.168.1.10
          ansible_network_os: ios
        switch-02:
          ansible_host: 192.168.1.11
          ansible_network_os: ios
        switch-03:                    # ← ADD THIS
          ansible_host: 192.168.1.12  # ← WITH IP
          ansible_network_os: ios     # ← AND OS TYPE
```

### Step 2: Verify the device is added
```bash
ansible-inventory --list | grep switch-03
```

### Step 3: Test connectivity
```bash
ansible switch-03 -m ping
```

### Step 4: Run a playbook to verify
```bash
ansible-playbook playbooks/testing/test_ping.yml --limit switch-03
```

## Complete Example: Removing a Device

### Step 1: Edit inventory/hosts.yml

Remove the device entry:
```yaml
switches:
  hosts:
    switch-01:
      ansible_host: 192.168.1.10
      ansible_network_os: ios
    # switch-02 removed
    switch-03:
      ansible_host: 192.168.1.12
      ansible_network_os: ios
```

### Step 2: Remove host variables (if exists)
```bash
rm host_vars/switch-02.yml
```

### Step 3: Verify device is removed
```bash
ansible-inventory --list | grep switch-02
# Should return nothing
```

## Advanced: Organizing by Sites/Locations

### Example: Multi-Site Inventory

```yaml
all:
  children:
    switches:
      children:
        datacenter1:
          hosts:
            dc1-switch-01:
              ansible_host: 10.1.1.10
              ansible_network_os: ios
            dc1-switch-02:
              ansible_host: 10.1.1.11
              ansible_network_os: ios
        datacenter2:
          hosts:
            dc2-switch-01:
              ansible_host: 10.2.1.10
              ansible_network_os: ios
            dc2-switch-02:
              ansible_host: 10.2.1.11
              ansible_network_os: ios
        office:
          hosts:
            office-switch-01:
              ansible_host: 10.3.1.10
              ansible_network_os: ios
```

### Usage with Site Groups
```bash
# Run on all switches in datacenter1
ansible-playbook playbooks/switches/backup_configs.yml --limit datacenter1

# Run on all switches except office
ansible-playbook playbooks/switches/backup_configs.yml --limit "switches:!office"
```

## Common Issues and Solutions

### Issue: Device not found after adding
**Solution:** Check YAML syntax (indentation, colons)
```bash
# Validate YAML syntax
ansible-inventory --list
```

### Issue: Connection timeout
**Solution:** Verify IP address and network connectivity
```bash
# Test ping
ping 192.168.1.10

# Test SSH
ssh admin@192.168.1.10
```

### Issue: Authentication failed
**Solution:** Check credentials in `group_vars/all.yml` or `host_vars/`
```bash
# Test with verbose output
ansible switch-01 -m ping -vvv
```

### Issue: Wrong OS type
**Solution:** Verify `ansible_network_os` matches device type
- IOS: `ios`
- IOS-XE: `iosxe`
- NX-OS: `nxos`
- ASA: `asa`

## Quick Reference

### Add Device
1. Open `inventory/hosts.yml`
2. Add device entry under appropriate group
3. Set `ansible_host` (IP address)
4. Set `ansible_network_os` (ios, iosxe, nxos, asa)
5. Save file
6. Test: `ansible <device-name> -m ping`

### Remove Device
1. Open `inventory/hosts.yml`
2. Delete device entry
3. Remove `host_vars/<device-name>.yml` if exists
4. Save file
5. Verify: `ansible-inventory --list`

### Verify Changes
```bash
# List all devices
ansible-inventory --list

# Test connectivity
ansible all -m ping

# Test specific device
ansible <device-name> -m ping
```

## Best Practices

1. **Use descriptive names**: `site1-core-switch-01` instead of `s1c1`
2. **Group logically**: Organize by location, function, or device type
3. **Use host_vars for unique settings**: Keep common settings in `group_vars/`
4. **Document changes**: Add comments for complex inventory structures
5. **Test after changes**: Always verify with `ansible-inventory` and `ping`
6. **Use Ansible Vault**: Encrypt passwords in inventory files
7. **Version control**: Commit inventory changes to track device additions/removals

## Example: Complete Inventory Structure

```yaml
---
# Cisco Ansible Inventory
# Example inventory structure for Cisco devices

all:
  children:
    # IOS Switches
    switches:
      children:
        core_switches:
          hosts:
            core-switch-01:
              ansible_host: 192.168.1.10
              ansible_network_os: ios
            core-switch-02:
              ansible_host: 192.168.1.11
              ansible_network_os: ios
        access_switches:
          hosts:
            access-switch-01:
              ansible_host: 192.168.1.20
              ansible_network_os: ios
            access-switch-02:
              ansible_host: 192.168.1.21
              ansible_network_os: ios
    
    # IOS-XE Routers
    routers:
      hosts:
        router-01:
          ansible_host: 192.168.1.30
          ansible_network_os: iosxe
        router-02:
          ansible_host: 192.168.1.31
          ansible_network_os: iosxe
    
    # NX-OS Switches
    nxos:
      hosts:
        nxos-switch-01:
          ansible_host: 192.168.1.40
          ansible_network_os: nxos
    
    # ASA Firewalls
    firewalls:
      hosts:
        asa-firewall-01:
          ansible_host: 192.168.1.50
          ansible_network_os: asa

  # Global variables (applied to all devices)
  vars:
    ansible_user: admin
    ansible_password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
    ansible_connection: network_cli
    ansible_network_cli_ssh_type: paramiko
```

## Summary

- **Adding**: Add device entry to `inventory/hosts.yml` with `ansible_host` and `ansible_network_os`
- **Removing**: Delete device entry from `inventory/hosts.yml` and remove `host_vars/` file if exists
- **Verifying**: Use `ansible-inventory --list` and `ansible <device> -m ping`
- **Organizing**: Use nested groups for sites, locations, or functions
- **Best Practice**: Test connectivity after any inventory changes

