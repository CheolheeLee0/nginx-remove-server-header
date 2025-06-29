#!/bin/bash

echo "Testing Server header..."

# Check Server header
SERVER_HEADER=$(curl -s -I http://localhost:8080 | grep -i "^server:")

if [ -z "$SERVER_HEADER" ]; then
    echo "❌ No Server header found"
    exit 1
elif echo "$SERVER_HEADER" | grep -q "nginx/" ; then
    echo "❌ Server header contains version: $SERVER_HEADER"
    exit 1
elif echo "$SERVER_HEADER" | grep -qi "^server: nginx$" ; then
    echo "✅ Server header shows only 'nginx' without version: $SERVER_HEADER"
else
    echo "ℹ️  Server header: $SERVER_HEADER"
fi