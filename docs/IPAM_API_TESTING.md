# IPAM API Testing with curl

## Overview

This guide shows how to test IPAM (IP Address Management) server API connectivity and authentication using curl commands on Ubuntu.

## Basic curl Command Structure

### General Format

```bash
curl -X METHOD \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  https://ipam-server.example.com/api/endpoint
```

## Common IPAM Systems

### 1. phpIPAM

#### Test API Key (Get Token)

```bash
# Get authentication token
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"your_username","password":"your_password"}' \
  https://ipam.example.com/api/user/

# Or with API key directly
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/user/
```

#### Test API Key - Get User Info

```bash
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/user/
```

#### Test API Key - List Subnets

```bash
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/subnets/
```

#### Test API Key - Get Specific Subnet

```bash
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/subnets/1/
```

### 2. NetBox

#### Test API Key - Get API Status

```bash
curl -X GET \
  -H "Authorization: Token YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  https://netbox.example.com/api/
```

#### Test API Key - Get Current User

```bash
curl -X GET \
  -H "Authorization: Token YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  https://netbox.example.com/api/users/users/me/
```

#### Test API Key - List IP Addresses

```bash
curl -X GET \
  -H "Authorization: Token YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  https://netbox.example.com/api/ipam/ip-addresses/
```

#### Test API Key - List Prefixes

```bash
curl -X GET \
  -H "Authorization: Token YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  https://netbox.example.com/api/ipam/prefixes/
```

### 3. Infoblox

#### Test API Key - Get Grid Info

```bash
curl -X GET \
  -u "admin:YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  https://infoblox.example.com/wapi/v2.11/grid
```

#### Test API Key - List Networks

```bash
curl -X GET \
  -u "admin:YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  https://infoblox.example.com/wapi/v2.11/network
```

## Complete Testing Examples

### Example 1: Test phpIPAM API Key

```bash
#!/bin/bash

# Configuration
IPAM_SERVER="https://ipam.example.com"
API_KEY="your_api_key_here"

# Test 1: Get user info (validates API key)
echo "Testing API key authentication..."
curl -X GET \
  -H "token: ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${IPAM_SERVER}/api/user/" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

# Test 2: List subnets
echo -e "\n\nListing subnets..."
curl -X GET \
  -H "token: ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${IPAM_SERVER}/api/subnets/" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s | jq '.'  # Pretty print JSON (requires jq)

# Check exit status
if [ $? -eq 0 ]; then
    echo -e "\n✅ API key is working!"
else
    echo -e "\n❌ API key test failed!"
    exit 1
fi
```

### Example 2: Test NetBox API Key

```bash
#!/bin/bash

# Configuration
NETBOX_SERVER="https://netbox.example.com"
API_KEY="your_api_key_here"

# Test 1: Get API status
echo "Testing NetBox API key..."
curl -X GET \
  -H "Authorization: Token ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${NETBOX_SERVER}/api/" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s | jq '.'

# Test 2: Get current user
echo -e "\n\nGetting current user info..."
curl -X GET \
  -H "Authorization: Token ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${NETBOX_SERVER}/api/users/users/me/" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s | jq '.'

# Test 3: List IP addresses
echo -e "\n\nListing IP addresses..."
curl -X GET \
  -H "Authorization: Token ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${NETBOX_SERVER}/api/ipam/ip-addresses/" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s | jq '.'
```

### Example 3: Simple One-Liner Test

```bash
# phpIPAM - Quick test
curl -X GET -H "token: YOUR_API_KEY" https://ipam.example.com/api/user/ -w "\nHTTP: %{http_code}\n"

# NetBox - Quick test
curl -X GET -H "Authorization: Token YOUR_API_KEY" https://netbox.example.com/api/ -w "\nHTTP: %{http_code}\n"
```

## curl Options Explained

### Common Options

| Option | Description |
|--------|-------------|
| `-X GET` | HTTP method (GET, POST, PUT, DELETE) |
| `-H "Header: Value"` | Add HTTP header |
| `-u "user:pass"` | Basic authentication |
| `-d '{"key":"value"}'` | POST data (JSON) |
| `-w "\nHTTP: %{http_code}\n"` | Show HTTP status code |
| `-s` | Silent mode (no progress bar) |
| `-v` | Verbose (debugging) |
| `-k` | Ignore SSL certificate errors |
| `--insecure` | Same as -k |
| `-o /dev/null` | Discard output |
| `-L` | Follow redirects |

## Testing Different Authentication Methods

### Bearer Token

```bash
curl -X GET \
  -H "Authorization: Bearer YOUR_API_KEY" \
  https://ipam.example.com/api/endpoint
```

### Token Header

```bash
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/endpoint
```

### API Key Header

```bash
curl -X GET \
  -H "X-API-Key: YOUR_API_KEY" \
  https://ipam.example.com/api/endpoint
```

### Basic Authentication

```bash
curl -X GET \
  -u "username:YOUR_API_KEY" \
  https://ipam.example.com/api/endpoint
```

## Troubleshooting

### Test 1: Basic Connectivity

```bash
# Test if server is reachable
curl -I https://ipam.example.com/api/

# Test with verbose output
curl -v https://ipam.example.com/api/
```

### Test 2: SSL Certificate Issues

```bash
# If you get SSL errors, test with -k (insecure)
curl -k -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/user/
```

### Test 3: Check HTTP Status Code

```bash
# Show only HTTP status code
curl -X GET \
  -H "token: YOUR_API_KEY" \
  -w "%{http_code}\n" \
  -o /dev/null \
  -s \
  https://ipam.example.com/api/user/

# Expected: 200 (OK)
# 401 = Unauthorized (wrong API key)
# 403 = Forbidden (no permission)
# 404 = Not Found (wrong endpoint)
```

### Test 4: View Full Response

```bash
# Show full response with headers
curl -X GET \
  -H "token: YOUR_API_KEY" \
  -i \
  https://ipam.example.com/api/user/
```

### Test 5: Save Response to File

```bash
# Save JSON response to file
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/subnets/ \
  -o response.json

# Pretty print and save
curl -X GET \
  -H "token: YOUR_API_KEY" \
  https://ipam.example.com/api/subnets/ \
  | jq '.' > response.json
```

## Common Error Responses

### 401 Unauthorized

```json
{
  "code": 401,
  "message": "Invalid API key"
}
```

**Solution:** Check API key is correct

### 403 Forbidden

```json
{
  "code": 403,
  "message": "Access denied"
}
```

**Solution:** API key is valid but user lacks permissions

### 404 Not Found

```json
{
  "code": 404,
  "message": "Endpoint not found"
}
```

**Solution:** Check API endpoint URL is correct

## Quick Test Script

Create a reusable test script:

```bash
#!/bin/bash
# test_ipam_api.sh

# Configuration
IPAM_SERVER="${1:-https://ipam.example.com}"
API_KEY="${2:-your_api_key}"

echo "Testing IPAM API..."
echo "Server: $IPAM_SERVER"
echo "API Key: ${API_KEY:0:10}..." # Show first 10 chars only

# Test API key
HTTP_CODE=$(curl -X GET \
  -H "token: ${API_KEY}" \
  -w "%{http_code}" \
  -o /tmp/ipam_response.json \
  -s \
  "${IPAM_SERVER}/api/user/")

echo -e "\nHTTP Status Code: $HTTP_CODE"

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ API key is valid!"
    echo "Response:"
    cat /tmp/ipam_response.json | jq '.' 2>/dev/null || cat /tmp/ipam_response.json
    exit 0
else
    echo "❌ API key test failed!"
    echo "Response:"
    cat /tmp/ipam_response.json
    exit 1
fi
```

**Usage:**
```bash
chmod +x test_ipam_api.sh
./test_ipam_api.sh https://ipam.example.com your_api_key
```

## Real-World Examples

### Example: Test phpIPAM API Key

```bash
# Replace with your actual values
IPAM_SERVER="https://ipam.example.com"
API_KEY="your_actual_api_key"

# Test authentication
curl -X GET \
  -H "token: ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${IPAM_SERVER}/api/user/" \
  -w "\n\nHTTP Status: %{http_code}\n" \
  -s | jq '.'
```

### Example: Test NetBox API Key

```bash
# Replace with your actual values
NETBOX_SERVER="https://netbox.example.com"
API_KEY="your_actual_api_key"

# Test authentication
curl -X GET \
  -H "Authorization: Token ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${NETBOX_SERVER}/api/users/users/me/" \
  -w "\n\nHTTP Status: %{http_code}\n" \
  -s | jq '.'
```

## Installing jq (JSON Parser)

For pretty JSON output, install jq:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y jq

# CentOS/RHEL
sudo yum install -y jq

# macOS
brew install jq
```

## Summary

### Quick Test Commands

**phpIPAM:**
```bash
curl -X GET -H "token: YOUR_API_KEY" https://ipam.example.com/api/user/ -w "\nHTTP: %{http_code}\n"
```

**NetBox:**
```bash
curl -X GET -H "Authorization: Token YOUR_API_KEY" https://netbox.example.com/api/ -w "\nHTTP: %{http_code}\n"
```

**Expected Results:**
- HTTP 200 = API key works ✅
- HTTP 401 = Invalid API key ❌
- HTTP 403 = Valid key but no permission ⚠️

