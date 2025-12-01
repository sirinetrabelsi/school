# CI/CD Pipeline Setup Script for School Application (Windows PowerShell)
# This script automates the initial setup of the CI/CD environment

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  School Application - CI/CD Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check command availability
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check Java Installation
Write-Host "[1/6] Checking Java installation..." -ForegroundColor Yellow
if (Test-Command java) {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java found: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Java is not installed" -ForegroundColor Red
    Write-Host "Please install Java 17 or higher" -ForegroundColor Red
    exit 1
}

# Check Maven Installation
Write-Host "[2/6] Checking Maven installation..." -ForegroundColor Yellow
if (Test-Command mvn) {
    $mvnVersion = mvn -version | Select-Object -First 1
    Write-Host "✓ Maven found: $mvnVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Maven is not installed" -ForegroundColor Red
    Write-Host "Please install Maven 3.8.x or higher" -ForegroundColor Red
    exit 1
}

# Check Git Installation
Write-Host "[3/6] Checking Git installation..." -ForegroundColor Yellow
if (Test-Command git) {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Git is not installed" -ForegroundColor Red
    Write-Host "Please install Git 2.30.x or higher" -ForegroundColor Red
    exit 1
}

# Build Maven Project
Write-Host ""
Write-Host "[4/6] Building Maven project..." -ForegroundColor Yellow
mvn clean install -DskipTests
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Maven build successful" -ForegroundColor Green
} else {
    Write-Host "✗ Maven build failed" -ForegroundColor Red
    exit 1
}

# Run Tests
Write-Host ""
Write-Host "[5/6] Running unit tests..." -ForegroundColor Yellow
mvn test
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Tests passed" -ForegroundColor Green
} else {
    Write-Host "⚠ Some tests may have failed (check logs)" -ForegroundColor Yellow
}

# Generate Coverage Report
Write-Host ""
Write-Host "[6/6] Generating code coverage report..." -ForegroundColor Yellow
mvn jacoco:report
if (Test-Path "target/site/jacoco/index.html") {
    Write-Host "✓ Coverage report generated: target/site/jacoco/index.html" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Configure Jenkinsfile in your repository"
Write-Host "2. Set up Jenkins server"
Write-Host "3. Install required Jenkins plugins"
Write-Host "4. Create pipeline job in Jenkins"
Write-Host "5. Configure credentials and tools"
Write-Host ""
Write-Host "For detailed instructions, see: CICD-PIPELINE-SETUP.md" -ForegroundColor Cyan
Write-Host ""
