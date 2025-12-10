# Ansible Performance Optimization Guide

## Why Ansible Can Be Slow

Ansible runs tasks **sequentially by default**, which means:
- If you have 5 switches, it processes them one at a time
- Each switch waits for the previous one to finish
- Total time = sum of all individual switch times

## Performance Optimizations Applied

### 1. Parallel Execution (`forks`)
- **Default**: `forks = 5` (processes 5 hosts at once)
- **Optimized**: `forks = 10` (processes 10 hosts simultaneously)
- **Result**: 5 switches now run in parallel instead of sequentially

### 2. Free Strategy (`strategy = free`)
- **Default**: `linear` - waits for all hosts to complete each task
- **Optimized**: `free` - hosts proceed independently, don't wait for others
- **Result**: Faster hosts don't wait for slower ones

### 3. Command Optimization
- Use **brief** commands instead of **detail** when possible
- `show cdp neighbors` is faster than `show cdp neighbors detail`
- Combine commands when safe: `terminal length 0` + `show command`

### 4. Timeout Optimization
- Reduced command timeouts from 60s to 30s for faster commands
- Quick SSH timeout (10s) for unreachable devices

## Expected Performance

**Before optimization:**
- 5 switches × 2 minutes each = **~10 minutes** (sequential)

**After optimization:**
- 5 switches ÷ 10 forks = **~1-2 minutes** (parallel)

## Additional Speed Tips

### Use `--limit` for testing:
```bash
# Test on one switch first
ansible-playbook playbooks/switches/network_topology_discovery.yml --limit switch-01
```

### Increase forks for more devices:
```bash
# Run with more parallel connections
ansible-playbook playbooks/switches/network_topology_discovery.yml -f 20
```

### Use async for long commands:
```yaml
- name: Long command
  cisco.ios.ios_command:
    commands:
      - show running-config
  async: 180
  poll: 5
```

### Skip unnecessary tasks:
```bash
# Skip specific tasks using tags
ansible-playbook playbooks/switches/network_topology_discovery.yml --skip-tags slow
```

## Monitoring Performance

### Check execution time:
```bash
time ansible-playbook playbooks/switches/network_topology_discovery.yml
```

### Verbose mode to see timing:
```bash
ansible-playbook playbooks/switches/network_topology_discovery.yml -vv
```

## Troubleshooting Slow Performance

1. **Check network latency**: Ping devices first
2. **Verify SSH connection speed**: Test manual SSH
3. **Check device CPU**: High CPU on switch = slow responses
4. **Reduce timeout if devices are fast**: Lower `ansible_command_timeout`
5. **Use persistent connections**: Already enabled in config

