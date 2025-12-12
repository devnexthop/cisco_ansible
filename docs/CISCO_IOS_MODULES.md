# Cisco IOS Ansible Modules Guide

## Overview: ios_config vs Specialized Modules

### `ios_config` - The "Catch-All" Module
- **Purpose**: Can configure ANYTHING on a Cisco IOS device
- **How it works**: Sends raw configuration commands (like typing in CLI)
- **Best for**: 
  - Quick one-off configurations
  - Configurations not covered by specialized modules
  - Legacy or complex configurations
- **Limitations**:
  - Not idempotent (may show "changed" even if config already exists)
  - Harder to read and maintain
  - Doesn't understand configuration state
  - Can be risky (may duplicate configs)

### Specialized Modules (ios_interfaces, ios_vlans, etc.)
- **Purpose**: Manage specific configuration areas with state awareness
- **How it works**: Understands the configuration structure and current state
- **Best for**:
  - Production automation
  - Idempotent operations (safe to run multiple times)
  - Better error handling
  - Easier to read and maintain
- **Advantages**:
  - ✅ Idempotent (won't change if already configured)
  - ✅ State management (can check if config exists)
  - ✅ Better validation
  - ✅ More readable playbooks
  - ✅ Follows Ansible best practices

## When to Use Which?

### Use `ios_config` When:
```yaml
# ✅ One-off or complex configurations
- name: Configure something not covered by specialized modules
  cisco.ios.ios_config:
    lines:
      - "ip route 0.0.0.0 0.0.0.0 192.168.1.1"
      - "ip name-server 8.8.8.8"
    parents: []
```

### Use Specialized Modules When:
```yaml
# ✅ Better: Use specialized module for interfaces
- name: Configure interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink to Core"
        enabled: true
```

## Complete Module Reference

### Core Modules

#### `cisco.ios.ios_command`
**Purpose**: Execute show commands and read-only operations
```yaml
- name: Show version
  cisco.ios.ios_command:
    commands:
      - show version
      - show inventory
```

#### `cisco.ios.ios_config`
**Purpose**: General configuration (catch-all)
```yaml
- name: Configure hostname
  cisco.ios.ios_config:
    lines:
      - "hostname SWITCH-01"
```

#### `cisco.ios.ios_facts`
**Purpose**: Gather device facts/information
```yaml
- name: Gather facts
  cisco.ios.ios_facts:
```

### Interface Modules

#### `cisco.ios.ios_interfaces`
**Purpose**: Configure physical interface properties

**Basic interface configuration:**
```yaml
- name: Configure interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink"
        enabled: true
        speed: 1000
        duplex: full
```

**Shut down (disable) an interface:**
```yaml
- name: Shut down interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        enabled: false  # false = shutdown, true = no shutdown
```

**Enable (no shut) an interface:**
```yaml
- name: Enable interface (no shutdown)
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        enabled: true  # true = no shutdown, false = shutdown
```

**Shut down multiple interfaces:**
```yaml
- name: Shut down multiple interfaces
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        enabled: false
      - name: GigabitEthernet0/2
        enabled: false
      - name: GigabitEthernet0/3
        enabled: false
```

**Enable multiple interfaces:**
```yaml
- name: Enable multiple interfaces
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        enabled: true
      - name: GigabitEthernet0/2
        enabled: true
      - name: GigabitEthernet0/3
        enabled: true
```

**Complete example: Configure interface with description and enable it:**
```yaml
- name: Configure and enable interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink to Core Switch"
        enabled: true    # no shutdown
        speed: 1000
        duplex: full
```

**Note:** 
- `enabled: true` = `no shutdown` (interface is up)
- `enabled: false` = `shutdown` (interface is down)

#### `cisco.ios.ios_l2_interfaces`
**Purpose**: Configure Layer 2 (switching) on interfaces
```yaml
- name: Configure L2 interface
  cisco.ios.ios_l2_interfaces:
    config:
      - name: GigabitEthernet0/1
        access:
          vlan: 100
        trunk:
          native_vlan: 1
          allowed_vlans: "100,200,300"
```

#### `cisco.ios.ios_l3_interfaces`
**Purpose**: Configure Layer 3 (routing) on interfaces
```yaml
- name: Configure L3 interface
  cisco.ios.ios_l3_interfaces:
    config:
      - name: GigabitEthernet0/1
        ipv4:
          - address: 192.168.1.1/24
```

#### `cisco.ios.ios_lag_interfaces`
**Purpose**: Configure Link Aggregation (Port Channels/EtherChannel)
```yaml
- name: Configure LAG
  cisco.ios.ios_lag_interfaces:
    config:
      - name: Port-channel1
        members:
          - member: GigabitEthernet0/1
          - member: GigabitEthernet0/2
        mode: active
```

### VLAN & Switching Modules

#### `cisco.ios.ios_vlans`
**Purpose**: Create and manage VLANs
```yaml
- name: Create VLANs
  cisco.ios.ios_vlans:
    config:
      - name: "VLAN_100"
        vlan_id: 100
        state: present
      - name: "VLAN_200"
        vlan_id: 200
        state: present
```

### Routing Modules

#### `cisco.ios.ios_static_routes`
**Purpose**: Configure static routes
```yaml
- name: Add static route
  cisco.ios.ios_static_routes:
    config:
      - address_families:
          - afi: ipv4
            routes:
              - dest: 0.0.0.0/0
                next_hops:
                  - forward_router_address: 192.168.1.1
```

#### `cisco.ios.ios_bgp_global`
**Purpose**: Configure BGP global settings
```yaml
- name: Configure BGP
  cisco.ios.ios_bgp_global:
    config:
      as_number: "65001"
      router_id: "192.168.1.1"
```

#### `cisco.ios.ios_ospfv2`
**Purpose**: Configure OSPFv2
```yaml
- name: Configure OSPF
  cisco.ios.ios_ospfv2:
    config:
      - process_id: 1
        router_id: "192.168.1.1"
        networks:
          - prefix: "192.168.1.0"
            area: "0.0.0.0"
```

### System & Management Modules

#### `cisco.ios.ios_hostname`
**Purpose**: Set device hostname
```yaml
- name: Set hostname
  cisco.ios.ios_hostname:
    hostname: "SWITCH-01"
```

#### `cisco.ios.ios_user`
**Purpose**: Manage user accounts
```yaml
- name: Create user
  cisco.ios.ios_user:
    config:
      - username: "admin"
        password: "password123"
        privilege: 15
        state: present
```

#### `cisco.ios.ios_ntp_global`
**Purpose**: Configure NTP
```yaml
- name: Configure NTP
  cisco.ios.ios_ntp_global:
    config:
      server:
        - server: "0.pool.ntp.org"
          source: "GigabitEthernet0/1"
```

#### `cisco.ios.ios_logging_global`
**Purpose**: Configure logging
```yaml
- name: Configure logging
  cisco.ios.ios_logging_global:
    config:
      hosts:
        - host: "192.168.1.100"
          name: "syslog-server"
```

#### `cisco.ios.ios_snmp_server`
**Purpose**: Configure SNMP
```yaml
- name: Configure SNMP
  cisco.ios.ios_snmp_server:
    config:
      communities:
        - name: "public"
          view: "default"
          ro: true
```

### Security Modules

#### `cisco.ios.ios_acls`
**Purpose**: Configure Access Control Lists
```yaml
- name: Configure ACL
  cisco.ios.ios_acls:
    config:
      - afi: ipv4
        acls:
          - name: "100"
            aces:
              - sequence: 10
                grant: permit
                source:
                  address: "192.168.1.0"
                  wildcard_bits: "0.0.0.255"
```

#### `cisco.ios.ios_banner`
**Purpose**: Configure login/motd banners
```yaml
- name: Set banner
  cisco.ios.ios_banner:
    banner: login
    text: "Authorized Access Only"
```

### Protocol Modules

#### `cisco.ios.ios_lldp_global`
**Purpose**: Configure LLDP globally
```yaml
- name: Enable LLDP
  cisco.ios.ios_lldp_global:
    config:
      holdtime: 120
      reinit: 2
      timer: 30
      tlv_select:
        system_name: true
```

#### `cisco.ios.ios_lldp_interfaces`
**Purpose**: Configure LLDP on interfaces
```yaml
- name: Configure LLDP on interface
  cisco.ios.ios_lldp_interfaces:
    config:
      - name: GigabitEthernet0/1
        receive: true
        transmit: true
```

#### `cisco.ios.ios_lacp`
**Purpose**: Configure LACP globally
```yaml
- name: Configure LACP
  cisco.ios.ios_lacp:
    config:
      system:
        priority: 32768
```

### VRF Modules

#### `cisco.ios.ios_vrf`
**Purpose**: Create VRFs
```yaml
- name: Create VRF
  cisco.ios.ios_vrf:
    config:
      - name: "VRF-1"
        description: "Customer VRF"
```

#### `cisco.ios.ios_vrf_interfaces`
**Purpose**: Assign interfaces to VRFs
```yaml
- name: Assign interface to VRF
  cisco.ios.ios_vrf_interfaces:
    config:
      - name: GigabitEthernet0/1
        vrf: "VRF-1"
```

### Utility Modules

#### `cisco.ios.ios_ping`
**Purpose**: Ping from the device
```yaml
- name: Ping from device
  cisco.ios.ios_ping:
    dest: "8.8.8.8"
    count: 5
```

## Practical Examples: Comparing Approaches

### Example 1: Configure Interface

#### Using `ios_config` (Not Recommended)
```yaml
- name: Configure interface with ios_config
  cisco.ios.ios_config:
    lines:
      - "description Uplink to Core"
      - "switchport mode trunk"
      - "switchport trunk native vlan 1"
      - "switchport trunk allowed vlan 100,200,300"
    parents: "interface GigabitEthernet0/1"
```
**Issues**: Not idempotent, harder to read, may duplicate configs

#### Using Specialized Modules (Recommended)
```yaml
- name: Configure interface properties
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink to Core"
        enabled: true

- name: Configure L2 properties
  cisco.ios.ios_l2_interfaces:
    config:
      - name: GigabitEthernet0/1
        trunk:
          native_vlan: 1
          allowed_vlans: "100,200,300"
```
**Benefits**: Idempotent, readable, state-aware

### Example 2: Configure VLAN

#### Using `ios_config`
```yaml
- name: Create VLAN
  cisco.ios.ios_config:
    lines:
      - "name VLAN_100"
    parents: "vlan 100"
```

#### Using Specialized Module (Better)
```yaml
- name: Create VLAN
  cisco.ios.ios_vlans:
    config:
      - name: "VLAN_100"
        vlan_id: 100
        state: present
```

### Example 3: Configure Hostname

#### Using `ios_config`
```yaml
- name: Set hostname
  cisco.ios.ios_config:
    lines:
      - "hostname SWITCH-01"
```

#### Using Specialized Module (Better)
```yaml
- name: Set hostname
  cisco.ios.ios_hostname:
    hostname: "SWITCH-01"
```

### Example 4: Shut Down / Enable Interface

#### Using `ios_config` (Not Recommended)
```yaml
- name: Shut down interface
  cisco.ios.ios_config:
    lines:
      - "shutdown"
    parents: "interface GigabitEthernet0/1"

- name: Enable interface (no shutdown)
  cisco.ios.ios_config:
    lines:
      - "no shutdown"
    parents: "interface GigabitEthernet0/1"
```
**Issues**: Not idempotent, requires separate tasks for shut/no shut

#### Using Specialized Module (Recommended)
```yaml
- name: Shut down interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        enabled: false  # false = shutdown

- name: Enable interface (no shutdown)
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        enabled: true   # true = no shutdown
```

**Or combine with other interface settings:**
```yaml
- name: Configure interface and enable it
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink to Core"
        enabled: true    # no shutdown
        speed: 1000
        duplex: full
```
**Benefits**: Idempotent, can combine multiple settings, state-aware

## Best Practices

### 1. Prefer Specialized Modules
```yaml
# ✅ GOOD: Use specialized module
- name: Configure interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink"

# ❌ AVOID: Using ios_config for everything
- name: Configure interface
  cisco.ios.ios_config:
    lines:
      - "description Uplink"
    parents: "interface GigabitEthernet0/1"
```

### 2. Use `ios_config` for Unsupported Features
```yaml
# ✅ GOOD: Use ios_config when no specialized module exists
- name: Configure custom feature
  cisco.ios.ios_config:
    lines:
      - "custom-command parameter value"
```

### 3. Combine Modules Appropriately
```yaml
# ✅ GOOD: Use multiple specialized modules together
- name: Configure interface
  cisco.ios.ios_interfaces:
    config:
      - name: GigabitEthernet0/1
        description: "Uplink"

- name: Configure L2
  cisco.ios.ios_l2_interfaces:
    config:
      - name: GigabitEthernet0/1
        access:
          vlan: 100
```

### 4. Use `ios_command` for Read-Only Operations
```yaml
# ✅ GOOD: Use ios_command for show commands
- name: Get version
  cisco.ios.ios_command:
    commands:
      - show version
```

## Quick Reference Table

| Task | Module | Alternative |
|------|--------|-------------|
| Show commands | `ios_command` | - |
| General config | `ios_config` | Specialized modules |
| Interface config | `ios_interfaces` | `ios_config` |
| L2 interface | `ios_l2_interfaces` | `ios_config` |
| L3 interface | `ios_l3_interfaces` | `ios_config` |
| VLANs | `ios_vlans` | `ios_config` |
| Static routes | `ios_static_routes` | `ios_config` |
| BGP | `ios_bgp_global` | `ios_config` |
| OSPF | `ios_ospfv2` | `ios_config` |
| Hostname | `ios_hostname` | `ios_config` |
| Users | `ios_user` | `ios_config` |
| NTP | `ios_ntp_global` | `ios_config` |
| SNMP | `ios_snmp_server` | `ios_config` |
| ACLs | `ios_acls` | `ios_config` |
| LLDP | `ios_lldp_global` | `ios_config` |
| VRF | `ios_vrf` | `ios_config` |

## Summary

- **`ios_config`**: Use for configurations not covered by specialized modules, or quick one-offs
- **Specialized modules**: Use for production automation - they're idempotent, safer, and more maintainable
- **`ios_command`**: Use for read-only operations (show commands)
- **Best practice**: Prefer specialized modules, fall back to `ios_config` when needed

## Getting Help

```bash
# View module documentation
ansible-doc cisco.ios.ios_interfaces
ansible-doc cisco.ios.ios_config
ansible-doc cisco.ios.ios_vlans

# List all Cisco IOS modules
ansible-doc -l | grep cisco.ios
```

