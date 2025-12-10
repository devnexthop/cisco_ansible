# Creating Playbooks for File Permissions (chmod/chown)

## Overview

This guide shows how to create Ansible playbooks to manage file and directory permissions using `chmod` and `chown` operations.

## Basic File Permissions Module

Ansible uses the `ansible.builtin.file` module to manage file permissions, ownership, and other file attributes.

## Basic Playbook Structure

### Simple Example: Set File Permissions

```yaml
---
- name: Set file permissions
  hosts: localhost
  gather_facts: yes
  
  tasks:
    - name: Set file permissions (chmod 644)
      ansible.builtin.file:
        path: /path/to/file.txt
        mode: '0644'
        state: file
```

## Common Permission Examples

### Set File Permissions (chmod)

```yaml
---
- name: Manage file permissions
  hosts: localhost
  gather_facts: yes
  
  tasks:
    # Common file permissions
    - name: Set file to 644 (rw-r--r--)
      ansible.builtin.file:
        path: /etc/config.conf
        mode: '0644'
        state: file
    
    - name: Set file to 755 (rwxr-xr-x)
      ansible.builtin.file:
        path: /usr/local/bin/script.sh
        mode: '0755'
        state: file
    
    - name: Set file to 600 (rw-------) - private
      ansible.builtin.file:
        path: /home/user/.ssh/id_rsa
        mode: '0600'
        state: file
    
    - name: Set file to 640 (rw-r-----)
      ansible.builtin.file:
        path: /etc/secret.conf
        mode: '0640'
        state: file
```

### Set Directory Permissions (chmod)

```yaml
---
- name: Manage directory permissions
  hosts: localhost
  gather_facts: yes
  
  tasks:
    - name: Set directory to 755 (rwxr-xr-x)
      ansible.builtin.file:
        path: /opt/myapp
        mode: '0755'
        state: directory
    
    - name: Set directory to 700 (rwx------) - private
      ansible.builtin.file:
        path: /home/user/private
        mode: '0700'
        state: directory
```

### Set Ownership (chown)

```yaml
---
- name: Manage file ownership
  hosts: localhost
  gather_facts: yes
  
  tasks:
    - name: Set file owner and group
      ansible.builtin.file:
        path: /opt/myapp/config.conf
        owner: myuser
        group: mygroup
        mode: '0644'
        state: file
    
    - name: Set directory owner and group
      ansible.builtin.file:
        path: /opt/myapp
        owner: myuser
        group: mygroup
        mode: '0755'
        state: directory
```

## Complete Example: Create File with Permissions

### Step 1: Create the playbook file

```bash
# Create new playbook
cp playbooks/switches/backup_configs.yml playbooks/system/set_file_permissions.yml

# Or create from scratch
nano playbooks/system/set_file_permissions.yml
```

### Step 2: Write the playbook

```yaml
---
- name: Set file permissions and ownership
  hosts: localhost
  gather_facts: yes
  become: yes  # Required for changing ownership of system files
  
  tasks:
    - name: Create directory with permissions
      ansible.builtin.file:
        path: /opt/myapp
        state: directory
        owner: myuser
        group: mygroup
        mode: '0755'
    
    - name: Create file with permissions
      ansible.builtin.file:
        path: /opt/myapp/config.conf
        state: touch  # Creates empty file
        owner: myuser
        group: mygroup
        mode: '0644'
    
    - name: Set permissions on existing file
      ansible.builtin.file:
        path: /etc/myapp.conf
        owner: root
        group: root
        mode: '0644'
```

## Permission Modes Reference

### Numeric Permissions (Octal)

| Mode | Permissions | Description |
|------|-------------|-------------|
| `0644` | rw-r--r-- | Owner: read/write, Others: read |
| `0755` | rwxr-xr-x | Owner: all, Others: read/execute |
| `0600` | rw------- | Owner: read/write, Others: none |
| `0640` | rw-r----- | Owner: read/write, Group: read |
| `0700` | rwx------ | Owner: all, Others: none |
| `0777` | rwxrwxrwx | Everyone: all (not recommended) |

### Symbolic Permissions

You can also use symbolic notation:

```yaml
- name: Set permissions using symbolic notation
  ansible.builtin.file:
    path: /opt/myapp/script.sh
    mode: 'u+rwx,g+rx,o+rx'  # Same as 0755
    state: file
```

## Advanced Examples

### Recursive Directory Permissions

```yaml
---
- name: Set permissions recursively
  hosts: localhost
  gather_facts: yes
  become: yes
  
  tasks:
    - name: Set directory and contents permissions
      ansible.builtin.file:
        path: /opt/myapp
        state: directory
        owner: myuser
        group: mygroup
        mode: '0755'
        recurse: yes  # Apply to all files/dirs inside
```

### Multiple Files with Loop

```yaml
---
- name: Set permissions on multiple files
  hosts: localhost
  gather_facts: yes
  become: yes
  
  vars:
    config_files:
      - /etc/app1.conf
      - /etc/app2.conf
      - /etc/app3.conf
  
  tasks:
    - name: Set permissions on config files
      ansible.builtin.file:
        path: "{{ item }}"
        owner: root
        group: root
        mode: '0644'
        state: file
      loop: "{{ config_files }}"
```

### Conditional Permissions

```yaml
---
- name: Set permissions conditionally
  hosts: localhost
  gather_facts: yes
  become: yes
  
  tasks:
    - name: Set secure permissions for sensitive file
      ansible.builtin.file:
        path: /etc/secret.conf
        mode: '0600'  # Only owner can read/write
        owner: root
        group: root
      when: sensitive_file == true
```

## Real-World Examples

### Example 1: Secure SSH Key Permissions

```yaml
---
- name: Secure SSH key permissions
  hosts: localhost
  gather_facts: yes
  
  tasks:
    - name: Set private key permissions (must be 600)
      ansible.builtin.file:
        path: ~/.ssh/id_rsa
        mode: '0600'
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        state: file
    
    - name: Set public key permissions
      ansible.builtin.file:
        path: ~/.ssh/id_rsa.pub
        mode: '0644'
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        state: file
    
    - name: Set .ssh directory permissions (must be 700)
      ansible.builtin.file:
        path: ~/.ssh
        mode: '0700'
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        state: directory
```

### Example 2: Application Directory Setup

```yaml
---
- name: Setup application directory with proper permissions
  hosts: localhost
  gather_facts: yes
  become: yes
  
  vars:
    app_user: myapp
    app_group: myapp
    app_dir: /opt/myapp
  
  tasks:
    - name: Create application directory
      ansible.builtin.file:
        path: "{{ app_dir }}"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: '0755'
    
    - name: Create config directory
      ansible.builtin.file:
        path: "{{ app_dir }}/config"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: '0755'
    
    - name: Create logs directory
      ansible.builtin.file:
        path: "{{ app_dir }}/logs"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: '0755'
    
    - name: Set executable script permissions
      ansible.builtin.file:
        path: "{{ app_dir }}/bin/start.sh"
        state: file
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: '0755'
    
    - name: Set config file permissions (readable by group)
      ansible.builtin.file:
        path: "{{ app_dir }}/config/app.conf"
        state: file
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: '0644'
```

### Example 3: Fix Permissions on Existing Files

```yaml
---
- name: Fix file permissions
  hosts: localhost
  gather_facts: yes
  become: yes
  
  tasks:
    - name: Find all files with wrong permissions
      ansible.builtin.find:
        paths: /opt/myapp
        file_type: file
        patterns: '*.conf'
      register: config_files
    
    - name: Fix permissions on config files
      ansible.builtin.file:
        path: "{{ item.path }}"
        mode: '0644'
        owner: myuser
        group: mygroup
      loop: "{{ config_files.files }}"
```

## Creating the Playbook Step-by-Step

### Step 1: Create directory structure (if needed)

```bash
mkdir -p playbooks/system
```

### Step 2: Create the playbook file

```bash
# Option 1: Create from scratch
nano playbooks/system/set_permissions.yml

# Option 2: Copy existing playbook as template
cp playbooks/switches/backup_configs.yml playbooks/system/set_permissions.yml
```

### Step 3: Write the playbook content

```yaml
---
- name: Set file permissions
  hosts: localhost
  gather_facts: yes
  become: yes  # Use 'yes' if changing system files
  
  tasks:
    - name: Your task here
      ansible.builtin.file:
        path: /path/to/file
        mode: '0644'
        owner: username
        group: groupname
        state: file
```

### Step 4: Test the playbook

```bash
# Syntax check
ansible-playbook playbooks/system/set_permissions.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbooks/system/set_permissions.yml --check

# Run the playbook
ansible-playbook playbooks/system/set_permissions.yml
```

## Important Notes

### Using `become: yes`

When changing ownership of system files or files owned by other users, you need elevated privileges:

```yaml
---
- name: Change system file ownership
  hosts: localhost
  become: yes  # Required for chown on system files
  
  tasks:
    - name: Change ownership
      ansible.builtin.file:
        path: /etc/system.conf
        owner: myuser
        group: mygroup
```

### File vs Directory

Always specify `state: file` or `state: directory`:

```yaml
# For files
- ansible.builtin.file:
    path: /path/to/file.txt
    state: file
    mode: '0644'

# For directories
- ansible.builtin.file:
    path: /path/to/directory
    state: directory
    mode: '0755'
```

### Recursive Permissions

Use `recurse: yes` to apply permissions to all files/directories inside:

```yaml
- ansible.builtin.file:
    path: /opt/myapp
    state: directory
    mode: '0755'
    recurse: yes  # Apply to all contents
```

## Quick Reference

### Basic Syntax

```yaml
- name: Set file permissions
  ansible.builtin.file:
    path: /path/to/file
    mode: '0644'        # chmod (octal)
    owner: username      # chown user
    group: groupname     # chown group
    state: file          # or 'directory'
    recurse: yes         # for directories (optional)
```

### Common Commands

```bash
# Create playbook
nano playbooks/system/set_permissions.yml

# Test syntax
ansible-playbook playbooks/system/set_permissions.yml --syntax-check

# Dry run
ansible-playbook playbooks/system/set_permissions.yml --check

# Run playbook
ansible-playbook playbooks/system/set_permissions.yml

# Run with become (sudo)
ansible-playbook playbooks/system/set_permissions.yml --become
```

## Troubleshooting

### Permission Denied

**Problem:** `Permission denied` when changing ownership

**Solution:** Add `become: yes` to the playbook:
```yaml
---
- name: Set permissions
  hosts: localhost
  become: yes  # Add this
```

### File Not Found

**Problem:** `File not found` error

**Solution:** Use `state: touch` to create file first:
```yaml
- ansible.builtin.file:
    path: /path/to/file
    state: touch  # Creates file if it doesn't exist
    mode: '0644'
```

### Wrong Permissions

**Problem:** Permissions not applied correctly

**Solution:** Check mode format (must be quoted string):
```yaml
mode: '0644'  # ✅ Correct (quoted)
mode: 0644    # ❌ Wrong (unquoted, may be interpreted as decimal)
```

## Summary

1. **Create playbook**: `nano playbooks/system/set_permissions.yml`
2. **Use `ansible.builtin.file` module**
3. **Set `mode`** for chmod (quoted octal: `'0644'`)
4. **Set `owner` and `group`** for chown
5. **Use `become: yes`** for system files
6. **Test**: `--syntax-check` and `--check` before running

