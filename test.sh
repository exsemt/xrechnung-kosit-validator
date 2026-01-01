#!/bin/bash
set -e

echo "🚀 Testing XRechnung KoSIT Validator..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Building Docker image...${NC}"
docker build -t xrechnung-validator-test .

echo -e "${YELLOW}🔧 Starting container...${NC}"
docker run -d --name xrechnung-validator-test -p 8080:8080 xrechnung-validator-test

echo -e "${YELLOW}⏳ Waiting for service to be ready...${NC}"
sleep 30

# Test health endpoint
echo -e "${YELLOW}🏥 Testing health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s http://localhost:8080/server/health)
if echo "$HEALTH_RESPONSE" | grep -q "UP"; then
    echo -e "${GREEN}✅ Health check passed${NC}"
else
    echo -e "${RED}❌ Health check failed${NC}"
    docker logs xrechnung-validator-test
    docker stop xrechnung-validator-test
    docker rm xrechnung-validator-test
    exit 1
fi

# Test validation with example file
if [ -f "examples/valid-xrechnung-cii.xml" ]; then
    echo -e "${YELLOW}📄 Testing validation with example invoice...${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
        --data-binary @examples/valid-xrechnung-cii.xml \
        http://localhost:8080/)

    if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 406 ]; then
        echo -e "${GREEN}✅ Validation endpoint working (HTTP $HTTP_CODE)${NC}"
    else
        echo -e "${RED}❌ Validation failed (HTTP $HTTP_CODE)${NC}"
        docker logs xrechnung-validator-test
        docker stop xrechnung-validator-test
        docker rm xrechnung-validator-test
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  No example file found, skipping validation test${NC}"
fi

# Cleanup
echo -e "${YELLOW}🧹 Cleaning up...${NC}"
docker stop xrechnung-validator-test
docker rm xrechnung-validator-test

echo -e "${GREEN}✅ All tests passed!${NC}"
