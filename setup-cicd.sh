#!/bin/bash

# CI/CD Pipeline Setup Script for School Application
# This script automates the initial setup of the CI/CD environment

set -e

echo "=========================================="
echo "  School Application - CI/CD Setup"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Java Installation
echo -e "${YELLOW}[1/6]${NC} Checking Java installation..."
if ! command -v java &> /dev/null; then
    echo -e "${RED}✗ Java is not installed${NC}"
    echo "Please install Java 17 or higher"
    exit 1
else
    JAVA_VERSION=$(java -version 2>&1 | grep -oP 'version "\K.*?(?=")' | head -1)
    echo -e "${GREEN}✓ Java $JAVA_VERSION found${NC}"
fi

# Check Maven Installation
echo -e "${YELLOW}[2/6]${NC} Checking Maven installation..."
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}✗ Maven is not installed${NC}"
    echo "Please install Maven 3.8.x or higher"
    exit 1
else
    MVN_VERSION=$(mvn -version | head -1)
    echo -e "${GREEN}✓ $MVN_VERSION found${NC}"
fi

# Check Git Installation
echo -e "${YELLOW}[3/6]${NC} Checking Git installation..."
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is not installed${NC}"
    echo "Please install Git 2.30.x or higher"
    exit 1
else
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓ $GIT_VERSION found${NC}"
fi

# Build Maven Project
echo ""
echo -e "${YELLOW}[4/6]${NC} Building Maven project..."
mvn clean install -DskipTests
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Maven build successful${NC}"
else
    echo -e "${RED}✗ Maven build failed${NC}"
    exit 1
fi

# Run Tests
echo ""
echo -e "${YELLOW}[5/6]${NC} Running unit tests..."
mvn test
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Tests passed${NC}"
else
    echo -e "${YELLOW}⚠ Some tests failed (non-critical)${NC}"
fi

# Generate Coverage Report
echo ""
echo -e "${YELLOW}[6/6]${NC} Generating code coverage report..."
mvn jacoco:report
if [ -f "target/site/jacoco/index.html" ]; then
    echo -e "${GREEN}✓ Coverage report generated: target/site/jacoco/index.html${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}  Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Configure Jenkinsfile in your repository"
echo "2. Set up Jenkins server"
echo "3. Install required Jenkins plugins"
echo "4. Create pipeline job in Jenkins"
echo "5. Configure credentials and tools"
echo ""
echo "For detailed instructions, see: CICD-PIPELINE-SETUP.md"
echo ""
