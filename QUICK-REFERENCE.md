# Quick Reference Guide - CI/CD Pipeline

## Files Created/Modified

### 1. **Jenkinsfile** (New)
- **Location**: Root of project
- **Purpose**: Defines the complete CI/CD pipeline with 5 stages
- **Key Stages**:
  1. Git Checkout
  2. Build & Compile
  3. SonarQube Analysis
  4. JUnit & Mockito Tests
  5. Deploy to Nexus

### 2. **pom.xml** (Modified)
- **Changes**:
  - Added Mockito dependencies
  - Added JUnit 5 dependencies
  - Added JaCoCo (code coverage) plugin
  - Added Surefire plugin for tests
  - Added SonarQube plugin
  - Added multiple Maven plugins

### 3. **sonar-project.properties** (New)
- **Location**: Root of project
- **Purpose**: SonarQube configuration
- **Key Settings**:
  - Project key: `tn.m104.rh:school`
  - Source: `src/main/java`
  - Tests: `src/test/java`

### 4. **.m2/settings.xml** (New)
- **Location**: `.m2` directory
- **Purpose**: Maven settings for Nexus
- **Includes**:
  - Server credentials
  - Repository configuration
  - Nexus URLs

### 5. **StudentServiceImplTest.java** (Modified)
- **Changes**:
  - Added comprehensive JUnit 5 test cases
  - Added Mockito mocking
  - Added AssertJ assertions
  - 12 test scenarios covering CRUD operations

### 6. **CICD-PIPELINE-SETUP.md** (New)
- **Location**: Root of project
- **Purpose**: Complete setup documentation
- **Includes**: Prerequisites, installation, configuration, troubleshooting

### 7. **setup-cicd.sh** (New)
- **Location**: Root of project
- **Purpose**: Automated setup script (Linux/Mac)

### 8. **setup-cicd.ps1** (New)
- **Location**: Root of project
- **Purpose**: Automated setup script (Windows PowerShell)

---

## Quick Start Commands

### 1. Run Local Build
```bash
cd school
mvn clean package
```

### 2. Run Tests Locally
```bash
mvn test
```

### 3. Generate Coverage Report
```bash
mvn jacoco:report
# View report at: target/site/jacoco/index.html
```

### 4. Run SonarQube Analysis Locally
```bash
mvn sonar:sonar \
  -Dsonar.projectKey=tn.m104.rh:school \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<your-token>
```

### 5. Deploy to Nexus Locally
```bash
mvn deploy
```

---

## Jenkins Setup Checklist

- [ ] Jenkins installed and running
- [ ] Maven tool configured in Jenkins
- [ ] JDK 17 configured in Jenkins
- [ ] Git tool configured in Jenkins
- [ ] SonarQube plugin installed
- [ ] Pipeline plugin installed
- [ ] Credentials configured for Nexus
- [ ] Credentials configured for SonarQube
- [ ] SonarQube server configured
- [ ] Pipeline job created
- [ ] Git repository URL configured
- [ ] Jenkinsfile path configured
- [ ] Build trigger configured (optional: webhook)

---

## Environment Configuration

### SonarQube Configuration (local)
```
URL: http://localhost:9000
Username: admin
Password: admin
Project Key: tn.m104.rh:school
```

### Nexus Configuration (local)
```
URL: http://localhost:8081
Repository: maven-releases
Repository URL: http://localhost:8081/repository/maven-releases/
Username: admin
Password: admin123
```

### Maven Configuration
```
JAVA_HOME: /path/to/java17
MAVEN_HOME: /path/to/maven3.9.0
M2_HOME: /path/to/maven3.9.0
```

---

## Test Results Interpretation

### Coverage Report
- **Line Coverage**: Percentage of lines executed during tests
- **Branch Coverage**: Percentage of decision branches tested
- **Complexity**: Cyclomatic complexity of code

### SonarQube Metrics
- **Code Smells**: Non-critical issues
- **Bugs**: Critical issues
- **Vulnerabilities**: Security issues
- **Duplications**: Code duplication percentage
- **Coverage**: Code coverage percentage

### Test Report
- **Total Tests**: All test cases executed
- **Passed**: Successful tests
- **Failed**: Failed tests (if any)
- **Skipped**: Skipped tests (if any)

---

## Troubleshooting Tips

### 1. Build Fails
```
Solution:
- Check Java version: java -version
- Check Maven version: mvn -version
- Clean local repo: rm -rf ~/.m2/repository
- Run: mvn clean install
```

### 2. Tests Fail
```
Solution:
- Run tests locally: mvn test
- Check test logs
- Debug specific test: mvn -Dtest=StudentServiceImplTest test
- Check mock setup
```

### 3. SonarQube Connection Error
```
Solution:
- Verify SonarQube running: http://localhost:9000
- Check token validity
- Verify project key
- Check firewall/network
```

### 4. Nexus Deployment Fails
```
Solution:
- Check credentials
- Verify repository URL
- Check Nexus running: http://localhost:8081
- Check network connectivity
```

---

## File Modifications Summary

| File | Type | Change | Impact |
|------|------|--------|--------|
| pom.xml | Modified | Added plugins/dependencies | Enables testing & coverage |
| Jenkinsfile | New | Pipeline stages | Automates CI/CD |
| sonar-project.properties | New | SonarQube config | Quality analysis |
| .m2/settings.xml | New | Maven/Nexus config | Repository access |
| StudentServiceImplTest.java | Modified | Enhanced tests | Better code coverage |

---

## Key Metrics to Monitor

1. **Build Success Rate**: Should be > 95%
2. **Test Coverage**: Target > 80%
3. **Code Quality**: Grade A (SonarQube)
4. **Deployment Time**: Should be < 5 minutes
5. **Test Execution Time**: Should be < 2 minutes

---

## Security Credentials

### Jenkins Credentials to Create
```
Credential 1:
- ID: nexus-credentials
- Type: Username/Password
- Username: admin
- Password: admin123

Credential 2:
- ID: sonarqube-token
- Type: Secret text
- Secret: <your-sonarqube-token>
```

### Environment Variables in Jenkins
```
NEXUS_URL = http://localhost:8081
SONARQUBE_URL = http://localhost:9000
GIT_REPO = https://github.com/yourusername/school.git
```

---

## Next Steps After Setup

1. **Verify Pipeline Runs**
   - Trigger build manually
   - Check all stages pass
   - Verify artifacts created

2. **Set Up Monitoring**
   - Monitor build trends
   - Track code quality metrics
   - Watch test coverage

3. **Configure Notifications** (Optional)
   - Email on failure
   - Slack integration
   - Teams integration

4. **Optimize Pipeline**
   - Parallelize stages where possible
   - Cache dependencies
   - Optimize build time

5. **Documentation**
   - Update README
   - Document custom steps
   - Create runbooks

---

## Support Resources

- **Jenkins Documentation**: https://www.jenkins.io/doc/
- **Maven Documentation**: https://maven.apache.org/
- **SonarQube Documentation**: https://docs.sonarqube.org/
- **Nexus Documentation**: https://help.sonatype.com/
- **Mockito Documentation**: https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html
- **JUnit 5 Documentation**: https://junit.org/junit5/docs/current/user-guide/

---

## Quick Verification Commands

```bash
# Verify Jenkinsfile syntax
mvn clean package

# Run all tests
mvn test -v

# Generate all reports
mvn clean test jacoco:report sonar:sonar

# Build and deploy
mvn clean deploy

# Check coverage
open target/site/jacoco/index.html

# Verify SonarQube project
curl http://localhost:9000/api/components/search_projects
```

---

**Last Updated**: December 1, 2025
**Status**: Ready for Production
**Version**: 1.0.0
