pipeline {
    agent any

    environment {
        // Git repository configuration
        GIT_REPO = 'https://github.com/sirinetrabelsi/school.git'
        GIT_BRANCH = 'master'
        
        // Maven configuration - system mvn is used
        MAVEN_OPTS = '-Xmx1024m -Xms512m'
        
        // SonarQube configuration
        SONARQUBE_SERVER = 'SonarQube'
        SONARQUBE_PROJECT_KEY = 'tn.m104.rh:school'
        SONARQUBE_PROJECT_NAME = 'School Application'
        
        // Nexus configuration
        NEXUS_URL = 'http://10.106.39.71:8081'
        NEXUS_REPO_ID = 'deploymentRepo'
        NEXUS_REPO_URL = 'http://10.106.39.71:8081/repository/maven-releases/'
        
        // Application configuration
        ARTIFACT_NAME = 'school'
        ARTIFACT_VERSION = '1.0.0'
        BUILD_DIR = 'target'
    }

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Git Checkout') {
            steps {
                script {
                    echo "============= Git Checkout Stage ============="
                    try {
                        // Clean workspace before checkout
                        deleteDir()
                        
                        // Clone from repository
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: "*/${GIT_BRANCH}"]],
                            userRemoteConfigs: [[url: GIT_REPO]]
                        ])
                        
                        echo "✓ Git checkout completed successfully"
                        echo "Repository: ${GIT_REPO}"
                        echo "Branch: ${GIT_BRANCH}"
                    } catch (Exception e) {
                        echo "✗ Git checkout failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Git checkout failed")
                    }
                }
            }
        }

        stage('Build & Compile') {
            steps {
                script {
                    echo "============= Build & Compile Stage ============="
                    try {
                        echo "Running Maven clean package..."
                        sh '''
                            mvn clean package -DskipTests \
                                -Dmaven.test.skip=true \
                                -Dorg.slf4j.simpleLogger.defaultLogLevel=info
                        '''
                        
                        echo "✓ Build and compilation completed successfully"
                        
                        // Verify JAR was created
                        if (fileExists("${BUILD_DIR}/${ARTIFACT_NAME}-${ARTIFACT_VERSION}.jar")) {
                            echo "✓ JAR file created: ${ARTIFACT_NAME}-${ARTIFACT_VERSION}.jar"
                        } else {
                            echo "⚠ Warning: Expected JAR file not found, but build may have succeeded"
                        }
                    } catch (Exception e) {
                        echo "✗ Build failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Maven build failed")
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            when {
                expression { currentBuild.result != 'FAILURE' }
            }
            steps {
                script {
                    echo "============= SonarQube Analysis Stage ============="
                    try {
                        withSonarQubeEnv('${SONARQUBE_SERVER}') {
                            sh '''
                                mvn sonar:sonar \
                                    -Dsonar.projectKey=${SONARQUBE_PROJECT_KEY} \
                                    -Dsonar.projectName="${SONARQUBE_PROJECT_NAME}" \
                                    -Dsonar.host.url=${SONAR_HOST_URL} \
                                    -Dsonar.login=${SONAR_AUTH_TOKEN} \
                                    -Dsonar.sources=src/main/java \
                                    -Dsonar.tests=src/test/java \
                                    -Dsonar.exclusions=**/target/**
                            '''
                        }
                        
                        echo "✓ SonarQube analysis completed"
                        
                        // Quality Gate check
                        timeout(time: 5, unit: 'MINUTES') {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                echo "⚠ SonarQube Quality Gate failed"
                                currentBuild.result = 'UNSTABLE'
                            } else {
                                echo "✓ SonarQube Quality Gate passed"
                            }
                        }
                    } catch (Exception e) {
                        echo "⚠ SonarQube analysis warning: ${e.message}"
                        // Don't fail the pipeline, just mark as unstable
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage('JUnit & Mockito Tests') {
            when {
                expression { currentBuild.result != 'FAILURE' }
            }
            steps {
                script {
                    echo "============= JUnit & Mockito Tests Stage ============="
                    try {
                        echo "Running JUnit tests with Mockito..."
                        sh '''
                            mvn test \
                                -Dorg.slf4j.simpleLogger.defaultLogLevel=info
                        '''
                        
                        echo "✓ JUnit tests completed"
                    } catch (Exception e) {
                        echo "✗ Test execution failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Tests failed")
                    }
                }
            }
            post {
                always {
                    // Generate and publish test reports
                    junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
                    
                    // Generate test report summary
                    script {
                        if (fileExists('target/surefire-reports')) {
                            echo "✓ Test reports published"
                        }
                    }
                }
            }
        }

        stage('Deploy to Nexus') {
            when {
                expression { currentBuild.result != 'FAILURE' }
            }
            steps {
                script {
                    echo "============= Deploy to Nexus Stage ============="
                    try {
                        echo "Deploying artifact to Nexus repository..."
                        
                        // Try to use credentials if available, otherwise skip deployment
                        try {
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
                            echo "✓ Deployment to Nexus completed successfully"
                        } catch (Exception credError) {
                            echo "⚠ Nexus credentials not configured: ${credError.message}"
                            echo "Skipping deployment to Nexus"
                            echo ""
                            echo "To enable deployment, configure credentials:"
                            echo "1. Go to Jenkins: Manage Jenkins → Manage Credentials"
                            echo "2. Add credential with ID: nexus-credentials"
                            echo "3. Type: Username with password"
                            echo "4. Username: admin"
                            echo "5. Password: [your Nexus admin password]"
                            echo ""
                            echo "Artifact available at: target/${ARTIFACT_NAME}-${ARTIFACT_VERSION}.jar"
                            currentBuild.result = 'UNSTABLE'
                        }
                        
                        echo "Repository URL: ${NEXUS_REPO_URL}"
                    } catch (Exception e) {
                        echo "✗ Deployment stage failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Deploy stage failed")
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo "============= Pipeline Summary ============="
                echo "Build Status: ${currentBuild.result ?: 'SUCCESS'}"
                echo "Build Number: ${env.BUILD_NUMBER}"
                echo "Build URL: ${env.BUILD_URL}"
                
                // Archive artifacts
                archiveArtifacts artifacts: "target/${ARTIFACT_NAME}-*.jar", 
                                  allowEmptyArchive: true
                
                // Clean workspace if needed (optional)
                // cleanWs()
            }
        }
        success {
            echo "✓ Pipeline completed successfully!"
            // Add notification here (email, Slack, etc.)
        }
        failure {
            echo "✗ Pipeline failed!"
            // Add notification here (email, Slack, etc.)
        }
        unstable {
            echo "⚠ Pipeline completed with warnings"
            // Add notification here (email, Slack, etc.)
        }
    }
}
