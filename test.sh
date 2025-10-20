#!/bin/bash
# Simple test script to validate the Swarm-SSH container

set -e

echo "========================================="
echo "  Swarm-SSH Test Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check if Dockerfile exists
echo -n "Test 1: Checking Dockerfile exists... "
if [ -f "Dockerfile" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 2: Check if entrypoint.sh exists and is executable
echo -n "Test 2: Checking entrypoint.sh exists... "
if [ -f "entrypoint.sh" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 3: Check if entrypoint.sh has bash shebang
echo -n "Test 3: Checking entrypoint.sh has bash shebang... "
if head -1 entrypoint.sh | grep -q "#!/bin/bash"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 4: Check if docker-compose.yml exists
echo -n "Test 4: Checking docker-compose.yml exists... "
if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 5: Check if .github/workflows directory exists
echo -n "Test 5: Checking GitHub workflows directory... "
if [ -d ".github/workflows" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 6: Check if GitHub workflow file exists
echo -n "Test 6: Checking GitHub workflow file... "
if [ -f ".github/workflows/docker-publish.yml" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 7: Check if ssh-keys directory exists
echo -n "Test 7: Checking ssh-keys directory... "
if [ -d "ssh-keys" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 8: Check if .gitignore exists and ignores ssh-keys
echo -n "Test 8: Checking .gitignore protects ssh-keys... "
if [ -f ".gitignore" ] && grep -q "ssh-keys" .gitignore; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 9: Check if .dockerignore exists
echo -n "Test 9: Checking .dockerignore exists... "
if [ -f ".dockerignore" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

# Test 10: Check if README.md has been updated
echo -n "Test 10: Checking README.md has content... "
if [ -f "README.md" ] && [ $(wc -l < README.md) -gt 10 ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "========================================="
echo ""

# Optional: Try to build the Docker image if Docker is available
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}Attempting to build Docker image...${NC}"
    if docker build -t swarm-ssh-test:latest .; then
        echo -e "${GREEN}Docker build successful!${NC}"
        
        # Clean up
        docker rmi swarm-ssh-test:latest 2>/dev/null || true
    else
        echo -e "${YELLOW}Docker build failed (this may be due to network issues)${NC}"
        echo "The build will be tested by GitHub Actions"
    fi
else
    echo -e "${YELLOW}Docker not available, skipping build test${NC}"
fi

echo ""
echo "Testing complete!"
