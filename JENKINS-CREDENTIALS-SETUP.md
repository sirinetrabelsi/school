# Jenkins Credentials Setup Guide

## Error: "Could not find credentials entry with ID 'nexus-credentials'"

Your pipeline failed because Jenkins doesn't have the Nexus credentials configured. This guide will show you how to add them.

---

## Step 1: Access Jenkins Credentials

### Via GUI (Easiest)
1. Go to Jenkins: `http://192.168.194.143:8080`
2. Click **Manage Jenkins** (left sidebar)
3. Click **Manage Credentials**
4. Click **System** (under "Stores scoped to Jenkins")
5. Click **Global credentials (unrestricted)**

---

## Step 2: Add Nexus Credentials

### Create New Credential
1. Click **+ Add Credentials** (top left)
2. Fill in the form:

| Field | Value |
|-------|-------|
| **Kind** | Username with password |
| **Scope** | Global (unrestricted) |
| **Username** | `admin` (or your Nexus username) |
| **Password** | Your Nexus admin password |
| **ID** | `nexus-credentials` ⚠️ **IMPORTANT** |
| **Description** | Nexus Repository Manager credentials |

3. Click **Create**

---

## Step 3: Verify Credentials

### Check Credentials are Saved
1. After clicking Create, you should see `nexus-credentials` in the list
2. Credentials should look like:
   ```
   nexus-credentials (Username with password)
   ```

---

## Step 4: Add SonarQube Token (Optional but Recommended)

If you want SonarQube analysis to work:

1. Click **+ Add Credentials** again
2. Fill in:

| Field | Value |
|-------|-------|
| **Kind** | Secret text |
| **Scope** | Global (unrestricted) |
| **Secret** | [SonarQube authentication token] |
| **ID** | `sonarqube-token` |
| **Description** | SonarQube authentication token |

3. Click **Create**

> **How to get SonarQube token:**
> 1. Go to `http://localhost:9000` (SonarQube)
> 2. Login as admin
> 3. Click profile (top right) → My Account → Security
> 4. Scroll to "Generate Tokens"
> 5. Create a token and copy it

---

## Step 5: Update Jenkinsfile (If Needed)

Your Jenkinsfile already uses the correct credential ID:

```groovy
withCredentials([usernamePassword(credentialsId: 'nexus-credentials', 
                                  usernameVariable: 'NEXUS_USER', 
                                  passwordVariable: 'NEXUS_PASS')]) {
    sh '''
        mvn deploy \
            -DskipTests \
            -Dorg.slf4j.simpleLogger.defaultLogLevel=info \
            -Dpom.version=${ARTIFACT_VERSION}
    '''
}
```

No changes needed!

---

## Step 6: Run Pipeline Again

Now that credentials are configured:

1. Go to Jenkins job: `http://192.168.194.143:8080/job/TP-6/`
2. Click **Build Now**
3. Monitor the build:
   - ✅ Git Checkout
   - ✅ Build & Compile
   - ⚠️ SonarQube Analysis (may be unstable if server not running)
   - ✅ JUnit Tests
   - ✅ Deploy to Nexus (should now work!)

---

## Verify Deployment

After successful pipeline run, verify artifact in Nexus:

```bash
# Check if JAR was deployed
curl -u admin:admin http://localhost:8081/service/rest/repository/browse/maven-releases/tn/m104/rh/school/1.0.0/

# Or visit in browser:
# http://localhost:8081/#browse/packages/maven-releases/tn/m104/rh/school
```

---

## Troubleshooting

### Issue: Still Can't Find Credentials

**Check 1: Verify credential ID matches exactly**
```groovy
// In Jenkinsfile, check this line:
credentialsId: 'nexus-credentials'

// Must match exactly what you created in Jenkins
```

**Check 2: Verify scope is Global**
1. Go to Manage Jenkins → Manage Credentials
2. Click on `nexus-credentials`
3. Confirm Scope is: "Global (unrestricted)"

**Check 3: Verify Jenkins user has permission**
```bash
# If Jenkins runs as specific user, may need permission adjustment
# Contact Jenkins administrator
```

### Issue: Authentication Failed at Nexus

**Symptom:** Credentials found but deployment still fails with 401 Unauthorized

**Solution:**
1. Verify Nexus credentials are correct
2. Test locally:
```bash
mvn deploy -DskipTests -DaltDeploymentRepository=deploymentRepo::default::http://localhost:8081/repository/maven-releases/
```

3. If that fails, Nexus credentials are wrong
4. Update Jenkins credentials with correct username/password

### Issue: "Maven command not found"

**Solution:** Maven is installed but not in PATH
```bash
# Check maven installation
which mvn
mvn --version

# If not found, configure Maven in Jenkins:
# 1. Manage Jenkins → Global Tool Configuration
# 2. Add Maven installation
# 3. Set MAVEN_HOME correctly
```

---

## All Required Credentials Summary

### For Full Pipeline Execution

| Credential | Type | ID | Where Used |
|-----------|------|----|-------------|
| Nexus | Username/Password | `nexus-credentials` | Deploy stage |
| SonarQube | Secret Text | `sonarqube-token` | SonarQube Analysis (optional) |
| GitHub | SSH Key or Token | `github-credentials` | Git Checkout (if private repo) |

### For Your Current Setup
- ✅ **Required**: `nexus-credentials` (username/password)
- ⚠️ **Optional**: `sonarqube-token` (if using SonarQube)
- ⓘ **Not needed**: GitHub credentials (public repo)

---

## Pipeline Execution Expected Output

After credentials are configured:

```
[Pipeline] stage
[Pipeline] { (Deploy to Nexus)
[Pipeline] script
[Pipeline] {
[Pipeline] echo
14:17:14  ============= Deploy to Nexus Stage =============
[Pipeline] withCredentials
[Pipeline] echo
14:17:14  Deploying artifact to Nexus repository...
[Pipeline] sh
14:17:15  Running Maven deploy...
14:17:30  ✓ Deployment to Nexus completed successfully
14:17:30  Artifact: school-1.0.0.jar
14:17:30  Repository URL: http://localhost:8081/repository/maven-releases/
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Declarative: Post Actions)
[Pipeline] echo
14:17:31  Build Status: SUCCESS
```

---

## Next Steps

1. ✅ Add Nexus credentials as shown above
2. ✅ (Optional) Add SonarQube token if you have SonarQube running
3. ✅ Run pipeline again: Click "Build Now"
4. ✅ Monitor deployment to Nexus
5. ✅ Verify artifact in Nexus repository

---

## Jenkins Credentials UI Reference

### Global Credentials Page
```
http://192.168.194.143:8080/credentials/store/system/domain/_/
```

### Add New Credential
```
http://192.168.194.143:8080/credentials/store/system/domain/_/newCredentials
```

---

## Security Best Practices

⚠️ **Important:**
- Never commit credentials to Git
- Use Jenkins Credentials Store (done ✅)
- Rotate credentials regularly
- Use tokens instead of passwords when possible
- Restrict credential access to necessary jobs
- Enable credential masking in logs

Your Jenkinsfile already masks credentials:
```groovy
withCredentials([usernamePassword(credentialsId: 'nexus-credentials', 
                                  usernameVariable: 'NEXUS_USER', 
                                  passwordVariable: 'NEXUS_PASS')])
```

The password won't appear in Jenkins logs ✅

---

## Support

For more information:
- Jenkins Credentials: https://www.jenkins.io/doc/book/using/using-credentials/
- Nexus: https://help.sonatype.com/repomanager3
