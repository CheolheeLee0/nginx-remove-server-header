#!/bin/bash

echo "Testing nginx setup..."

# Test 1: Check if page loads
echo "1. Testing page response..."
if curl -s -f http://localhost:8080 > /dev/null; then
    echo "✅ Page loads successfully"
else
    echo "❌ Page failed to load"
    exit 1
fi

# Test 2: Check Server header
echo "2. Testing Server header..."
SERVER_HEADER=$(curl -s -I http://localhost:8080 | grep -i "^server:")

if [ -z "$SERVER_HEADER" ]; then
    echo "✅ Server header completely removed"
elif echo "$SERVER_HEADER" | grep -q "nginx/" ; then
    echo "❌ Server header contains version: $SERVER_HEADER"
    exit 1
elif echo "$SERVER_HEADER" | grep -qi "^server: nginx$" ; then
    echo "✅ Server header shows only 'nginx' without version: $SERVER_HEADER"
else
    echo "ℹ️  Server header: $SERVER_HEADER"
fi

echo "✅ All tests passed!"