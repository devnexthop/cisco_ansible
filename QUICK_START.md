# Quick Start Guide

## Copying Files to Create New Ones

### Copy a Playbook

```bash
# Copy a playbook to create a new one
cp playbooks/switches/backup_configs.yml playbooks/switches/my_new_playbook.yml

# Then edit it
nano playbooks/switches/my_new_playbook.yml
# or
vim playbooks/switches/my_new_playbook.yml
# or use your preferred editor
```

### Copy an Inventory File

```bash
# Copy inventory file
cp inventory/hosts.yml inventory/hosts_backup.yml

# Or create a new inventory for different environment
cp inventory/hosts.yml inventory/hosts_production.yml
```

### Copy Configuration Files

```bash
# Copy ansible.cfg
cp ansible.cfg ansible.cfg.backup

# Copy group_vars
cp group_vars/all.yml group_vars/all_backup.yml
```

### Copy Documentation Files

```bash
# Copy a guide
cp INVENTORY_MANAGEMENT.md MY_CUSTOM_GUIDE.md
```

## Common Workflow: Create New Playbook from Template

### Step 1: Copy existing playbook
```bash
cd /Users/marcinzgola/cisco_ansible
cp playbooks/switches/backup_configs.yml playbooks/switches/my_custom_playbook.yml
```

### Step 2: Edit the new file
```bash
# Using nano (simple editor)
nano playbooks/switches/my_custom_playbook.yml

# Using vim (advanced editor)
vim playbooks/switches/my_custom_playbook.yml

# Using VS Code (if installed)
code playbooks/switches/my_custom_playbook.yml
```

### Step 3: Update the playbook content
Change:
- Play name
- Task names
- Commands/variables
- Host groups

### Step 4: Test the new playbook
```bash
ansible-playbook playbooks/switches/my_custom_playbook.yml --check
```

## Examples

### Example 1: Create New Switch Playbook
```bash
# Copy existing playbook
cp playbooks/switches/verify_switch_versions.yml playbooks/switches/check_switch_health.yml

# Edit it
nano playbooks/switches/check_switch_health.yml
```

### Example 2: Create New Inventory for Testing
```bash
# Copy inventory
cp inventory/hosts.yml inventory/hosts_test.yml

# Edit test inventory
nano inventory/hosts_test.yml
```

### Example 3: Backup Before Changes
```bash
# Backup current inventory
cp inventory/hosts.yml inventory/hosts.yml.backup

# Make changes to original
nano inventory/hosts.yml
```

## Using Git (Recommended)

If you want to track changes:

```bash
# Copy file
cp playbooks/switches/backup_configs.yml playbooks/switches/my_new_playbook.yml

# Edit it
nano playbooks/switches/my_new_playbook.yml

# Add to git
git add playbooks/switches/my_new_playbook.yml
git commit -m "Add new playbook based on backup_configs"
git push
```

## Quick Copy Commands Reference

```bash
# Basic copy
cp source_file.yml destination_file.yml

# Copy with full path
cp /path/to/source.yml /path/to/destination.yml

# Copy to different directory
cp playbooks/switches/old.yml playbooks/routers/new.yml

# Copy and preserve permissions
cp -p source.yml destination.yml

# Copy and show progress (if using rsync)
rsync -av source.yml destination.yml
```

## Editing Files

### Using Nano (Beginner-friendly)
```bash
nano filename.yml
# Ctrl+X to exit, Y to save, N to cancel
```

### Using Vim (Advanced)
```bash
vim filename.yml
# Press 'i' to insert/edit
# Press 'Esc' then ':wq' to save and quit
# Press 'Esc' then ':q!' to quit without saving
```

### Using VS Code
```bash
code filename.yml
# Or open in your IDE
```

## Tips

1. **Always backup before major changes:**
   ```bash
   cp inventory/hosts.yml inventory/hosts.yml.backup
   ```

2. **Use descriptive names:**
   ```bash
   cp backup_configs.yml backup_configs_with_validation.yml
   ```

3. **Keep original intact:**
   ```bash
   # Good: Creates new file
   cp original.yml new_version.yml
   
   # Bad: Overwrites original
   cp new.yml original.yml  # Don't do this!
   ```

4. **Test new files:**
   ```bash
   # Validate YAML syntax
   ansible-playbook new_file.yml --syntax-check
   
   # Dry run
   ansible-playbook new_file.yml --check
   ```

