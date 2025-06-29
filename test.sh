#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ "$1" = "SUCCESS" ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $2"
    elif [ "$1" = "FAIL" ]; then
        echo -e "${RED}[FAIL]${NC} $2"
    elif [ "$1" = "INFO" ]; then
        echo -e "${YELLOW}[INFO]${NC} $2"
    fi
}

# Test configuration
NGINX_URL="http://localhost:8080"
WAIT_TIME=5

print_status "INFO" "Starting nginx server header removal test..."

# Check if Docker Compose is running
print_status "INFO" "Checking if Docker Compose services are running..."
if ! docker-compose ps | grep -q "nginx-no-server-header.*Up"; then
    print_status "INFO" "Starting Docker Compose services..."
    docker-compose up -d
    
    # Wait for nginx to start
    print_status "INFO" "Waiting ${WAIT_TIME} seconds for nginx to start..."
    sleep $WAIT_TIME
fi

# Test 1: Check if nginx is responding
print_status "INFO" "Test 1: Checking if nginx is responding..."
if curl -s -f "$NGINX_URL" > /dev/null; then
    print_status "SUCCESS" "Nginx is responding on $NGINX_URL"
else
    print_status "FAIL" "Nginx is not responding on $NGINX_URL"
    exit 1
fi

# Test 2: Check if Server header is present
print_status "INFO" "Test 2: Checking for Server header..."
SERVER_HEADER=$(curl -s -I "$NGINX_URL" | grep -i "^server:")

if [ -z "$SERVER_HEADER" ]; then
    print_status "SUCCESS" "Server header is successfully removed!"
else
    print_status "FAIL" "Server header is still present: $SERVER_HEADER"
    exit 1
fi

# Test 3: Check response headers
print_status "INFO" "Test 3: Displaying all response headers..."
echo "Response headers from $NGINX_URL:"
echo "----------------------------------------"
curl -s -I "$NGINX_URL"
echo "----------------------------------------"

# Test 4: Check security headers
print_status "INFO" "Test 4: Checking security headers..."
HEADERS=$(curl -s -I "$NGINX_URL")

# Check X-Frame-Options
if echo "$HEADERS" | grep -qi "x-frame-options"; then
    print_status "SUCCESS" "X-Frame-Options header is present"
else
    print_status "FAIL" "X-Frame-Options header is missing"
fi

# Check X-Content-Type-Options
if echo "$HEADERS" | grep -qi "x-content-type-options"; then
    print_status "SUCCESS" "X-Content-Type-Options header is present"
else
    print_status "FAIL" "X-Content-Type-Options header is missing"
fi

# Check X-XSS-Protection
if echo "$HEADERS" | grep -qi "x-xss-protection"; then
    print_status "SUCCESS" "X-XSS-Protection header is present"
else
    print_status "FAIL" "X-XSS-Protection header is missing"
fi

print_status "SUCCESS" "All tests completed!"

# Optional: Stop Docker Compose services
read -p "Do you want to stop the Docker Compose services? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "INFO" "Stopping Docker Compose services..."
    docker-compose down
fi