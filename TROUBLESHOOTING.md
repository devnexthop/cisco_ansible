# Troubleshooting Guide

## Ansible Getting Stuck During Execution

If Ansible playbooks are getting stuck halfway through execution, here are common causes and solutions:

### 1. Command Timeout Issues

**Problem:** Long-running commands (like `show spanning-tree`, `show running-config`) timeout.

**Solution:**
- Timeouts have been increased in `ansible.cfg` and `group_vars/all.yml`
- All playbooks now include `terminal length 0` to disable paging
- Individual tasks have timeout parameters set

**Check current timeout settings:**
```bash
grep -r "ansible_command_timeout" ansible.cfg group_vars/
```

### 2. Paging Issues

**Problem:** Commands waiting for "more" prompts.

**Solution:** All playbooks now include `terminal length 0` before show commands.

**Manual fix:** Add to your playbook tasks:
```yaml
- name: Disable paging
  cisco.ios.ios_command:
    commands:
      - terminal length 0
```

### 3. Connection Timeout Issues

**Problem:** SSH connections timing out or hanging.

**Solution:**
- Updated `ansible.cfg` with better SSH keepalive settings
- Increased connection timeouts
- Added connection retry logic

**Test connectivity:**
```bash
ansible switches -m ping
```

### 4. Device Not Responding

**Problem:** Specific device is unresponsive.

**Solution:**
- Run playbook with `--limit` to test individual devices:
```bash
ansible-playbook playbooks/switches/verify_spanning_tree.yml --limit ios-switch-01
```

### 5. Debug Mode

**Enable verbose output:**
```bash
ansible-playbook playbooks/switches/verify_spanning_tree.yml -vvv
```

**Check what task is hanging:**
```bash
ansible-playbook playbooks/switches/verify_spanning_tree.yml --step
```

### 6. Force Disconnect Stuck Connections

**If Ansible is completely stuck:**
```bash
# Kill Ansible process
pkill -f ansible-playbook

# Clear SSH control sockets
rm -rf ~/.ansible/cp/
```

### 7. Test Individual Commands

**Test a specific command manually:**
```bash
ansible switches -m cisco.ios.ios_command -a "commands='terminal length 0'"
ansible switches -m cisco.ios.ios_command -a "commands='show version'"
```

### 8. Check Device Logs

**On the switch, check for connection issues:**
```bash
show users
show logging | include SSH
```

### 9. Increase Timeouts Further

**If still having issues, increase timeouts in `group_vars/all.yml`:**
```yaml
ansible_command_timeout: 300  # 5 minutes
ansible_persistent_command_timeout: 300
```

### 10. Use Async Tasks for Long Commands

**For very long commands, use async:**
```yaml
- name: Long running command
  cisco.ios.ios_command:
    commands:
      - show spanning-tree
  async: 300
  poll: 10
  register: result
```

## Common Error Messages

### "Timeout waiting for command"
- Increase `ansible_command_timeout` in group_vars/all.yml
- Check network connectivity to device

### "Connection closed"
- Check SSH service on device
- Verify credentials
- Check firewall rules

### "Command execution failed"
- Verify command syntax
- Check device supports the command
- Review device logs

## Best Practices

1. **Always use `terminal length 0`** before show commands
2. **Set appropriate timeouts** for long commands
3. **Test with single device first** using `--limit`
4. **Use verbose mode** (`-vvv`) to debug issues
5. **Check device connectivity** before running playbooks

