# CI/CD Pipeline Setup - School Application

## Overview

This document provides comprehensive setup instructions for the CI/CD pipeline for the School Application using Jenkins, Maven, SonarQube, and Nexus Repository Manager.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Jenkins Pipeline                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │  Git     │    │  Build & │    │ SonarQube│    │  JUnit & │      │
│  │Checkout  │───▶│ Compile  │───▶│ Analysis │───▶│ Mockito  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘      │
│                                                          │            │
│                                                          ▼            │
│                                                   ┌──────────────┐   │
│                                                   │Deploy Nexus  │   │
│                                                   └──────────────┘   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Software Requirements
- **Jenkins** 2.387.x or higher
- **Maven** 3.8.x or higher
- **Java** 17 JDK
- **Git** 2.30.x or higher
- **SonarQube** 9.9.x or higher
- **Nexus Repository Manager** 3.40.x or higher

### Jenkins Plugins Required
1. **Pipeline Plugin** - For declarative pipeline support
2. **Git Plugin** - For Git integration
3. **Maven Integration Plugin** - For Maven builds
4. **SonarQube Scanner for Jenkins** - For SonarQube integration
5. **Cobertura Plugin** - For code coverage reports
6. **JUnit Plugin** - For test result publishing (usually pre-installed)
7. **Credentials Plugin** - For managing credentials
8. **Email Extension Plugin** - For email notifications (optional)

## Installation & Configuration

### 1. Install Jenkins Plugins

Go to **Manage Jenkins** → **Manage Plugins** → **Available Plugins**

Search and install the following plugins:
```
- Pipeline
- Git
- Maven Integration
- SonarQube Scanner
- Cobertura
- Email Extension
```

Click **Install without restart** and check the **Restart Jenkins when installation is complete** option.

### 2. Configure Git Tool

1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Scroll to **Git**
3. Set Git executable path (usually auto-detected)

### 3. Configure Maven

1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Scroll to **Maven**
3. Click **Add Maven**
4. Name: `Maven-3.9.0`
5. Choose **Install automatically**
6. Select version `3.9.0`
7. Click **Save**

### 4. Configure JDK

1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Scroll to **JDK**
3. Click **Add JDK**
4. Name: `Java-17`
5. Choose **Install automatically**
6. Accept Oracle License Agreement
7. Click **Save**

### 5. Configure SonarQube Server

#### In Jenkins:
1. Go to **Manage Jenkins** → **Configure System**
2. Scroll to **SonarQube servers**
3. Click **Add SonarQube**
4. Name: `SonarQube`
5. Server URL: `http://localhost:9000` (or your SonarQube URL)
6. Server authentication token: [Get from SonarQube]
7. Click **Save**

#### In SonarQube:
1. Login to SonarQube (usually `http://localhost:9000`)
2. Go to **My Account** → **Security** → **Generate Tokens**
3. Create a token (e.g., `jenkins-token`)
4. Copy the token to Jenkins

### 6. Configure Nexus Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **global** (in System)
3. Click **Add Credentials**
4. Kind: **Username with password**
5. Username: `admin`
6. Password: `admin123` (your Nexus password)
7. ID: `nexus-credentials`
8. Description: `Nexus Repository Credentials`
9. Click **Create**

## Create Jenkins Job

### Step 1: Create New Pipeline Job

1. Click **New Item** on Jenkins dashboard
2. Enter name: `school-app-cicd`
3. Select **Pipeline**
4. Click **OK**

### Step 2: Configure Pipeline

1. Scroll to **Pipeline** section
2. Definition: **Pipeline script from SCM**
3. SCM: **Git**
4. Repository URL: `https://github.com/yourusername/school.git`
5. Branch Specifier: `*/main`
6. Script Path: `Jenkinsfile`
7. Click **Save**

## Jenkinsfile Overview

The provided `Jenkinsfile` includes the following stages:

### Stage 1: Git Checkout
```groovy
- Clones the project from the remote repository
- Branch: main
- Cleans workspace before checkout
```

### Stage 2: Build & Compile
```groovy
- Runs: mvn clean package -DskipTests
- Skips tests during build phase
- Generates JAR artifact
```

### Stage 3: SonarQube Analysis
```groovy
- Runs: mvn sonar:sonar
- Analyzes code quality
- Checks against Quality Gate
- Reports violations and code smells
```

### Stage 4: JUnit & Mockito Tests
```groovy
- Runs: mvn test
- Executes all unit tests
- Uses Mockito for mocking
- Publishes test reports
```

### Stage 5: Deploy to Nexus
```groovy
- Runs: mvn deploy
- Deploys JAR to Nexus Repository
- Uses credentials from Jenkins Credentials
```

## POM.xml Configuration

### Required Dependencies Added:
```xml
<!-- Mockito for Unit Testing -->
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>5.7.1</version>
    <scope>test</scope>
</dependency>

<!-- JaCoCo for Code Coverage -->
<dependency>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
</dependency>
```

### Required Plugins Added:
```xml
<!-- Surefire Plugin for Tests -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.1.2</version>
</plugin>

<!-- JaCoCo Plugin for Coverage -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
</plugin>

<!-- SonarQube Plugin -->
<plugin>
    <groupId>org.sonarsource.scanner.maven</groupId>
    <artifactId>sonar-maven-plugin</artifactId>
    <version>3.10.0.2594</version>
</plugin>
```

## Environment Variables

The Jenkinsfile uses the following environment variables:

```groovy
GIT_REPO = 'https://github.com/yourusername/school.git'
GIT_BRANCH = 'main'
MAVEN_HOME = tool 'Maven-3.9.0'
SONARQUBE_SERVER = 'SonarQube'
SONARQUBE_PROJECT_KEY = 'tn.m104.rh:school'
NEXUS_URL = 'http://localhost:8081'
NEXUS_REPO_ID = 'deploymentRepo'
ARTIFACT_NAME = 'school'
ARTIFACT_VERSION = '1.0.0'
```

## Running the Pipeline

### Manual Trigger:
1. Go to Jenkins job `school-app-cicd`
2. Click **Build Now**
3. Monitor build progress in **Console Output**

### Git Webhook Trigger (Optional):
1. Go to your GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: `http://jenkins-url:8080/github-webhook/`
4. Content type: `application/json`
5. Events: **Push events**
6. Click **Add webhook**

## Monitoring & Logging

### Console Output:
- Real-time build logs
- Stage execution status
- Error messages and stack traces

### Build Artifacts:
- JAR file: `target/school-1.0.0.jar`
- Test reports: `target/surefire-reports/`
- Coverage report: `target/site/jacoco/`

### SonarQube Dashboard:
- Access at: `http://localhost:9000`
- Project: `tn.m104.rh:school`
- Metrics: Code coverage, violations, duplications

### Nexus Repository:
- Access at: `http://localhost:8081`
- Repository: `maven-releases`
- Path: `tn/m104/rh/school/1.0.0/`

## Test Cases

The project includes comprehensive test cases using JUnit 5 and Mockito:

### Test File: `StudentServiceImplTest.java`

**Test Scenarios:**
- ✓ Get all students
- ✓ Get student by ID
- ✓ Register/Add student
- ✓ Update student
- ✓ Delete student
- ✓ Error handling

**Mock Dependencies:**
- `StudentRepository` (mocked)

**Assertions:**
- Using AssertJ for fluent assertions
- Mockito verification for method calls

## Troubleshooting

### Common Issues & Solutions

#### 1. Build Fails - Git Checkout Error
```
Error: "Repository not found"
Solution: 
- Verify Git credentials
- Check repository URL
- Ensure branch exists
```

#### 2. Maven Build Fails
```
Error: "Maven home directory not found"
Solution:
- Configure Maven in Global Tool Configuration
- Check MAVEN_HOME variable
- Verify Maven installation
```

#### 3. SonarQube Connection Error
```
Error: "Unable to connect to SonarQube server"
Solution:
- Verify SonarQube is running
- Check server URL configuration
- Verify authentication token
```

#### 4. Nexus Deployment Fails
```
Error: "Authentication failed"
Solution:
- Verify Nexus credentials in Jenkins
- Check credentials ID in Jenkinsfile
- Verify Nexus server URL
```

#### 5. Test Failures
```
Error: "Tests failed: X failures"
Solution:
- Check test logs in Console Output
- Review test assertions
- Debug test data setup
```

## Pipeline Performance Tips

1. **Skip Tests During Build**: Use `-DskipTests` flag (already done)
2. **Parallel Stages**: Can be configured for independent stages
3. **Artifact Caching**: Cache dependencies locally
4. **Timeout Configuration**: Set appropriate timeouts (1 hour default)
5. **Build History**: Keep last 10 builds (configurable)

## Security Best Practices

1. ✓ Use Jenkins Credentials for sensitive data
2. ✓ Enable authentication for Jenkins
3. ✓ Use HTTPS for all external connections
4. ✓ Restrict pipeline job access
5. ✓ Rotate Nexus and SonarQube tokens regularly
6. ✓ Use SSH keys instead of username/password (optional)

## Maintenance

### Regular Tasks:
- Monitor build success rate
- Review code quality trends
- Update dependencies monthly
- Clean up old builds
- Verify SonarQube token validity

### Log Retention:
- Keep last 10 builds (configurable)
- Archive test reports
- Monitor Jenkins disk space

## Support & Documentation

- Jenkins: https://www.jenkins.io/doc/
- Maven: https://maven.apache.org/guides/
- SonarQube: https://docs.sonarqube.org/
- Nexus: https://help.sonatype.com/

## Summary

This CI/CD pipeline automates:
✓ Code checkout from Git
✓ Maven compilation and packaging
✓ Code quality analysis with SonarQube
✓ Comprehensive unit testing with Mockito
✓ Artifact deployment to Nexus

All stages include proper error handling, logging, and verification steps.

---

**Last Updated:** December 1, 2025
**Version:** 1.0.0
