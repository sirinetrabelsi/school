# Complete Docker & Docker Compose Setup Guide

## Overview

This guide explains how to deploy your Spring Boot "School" application with MySQL database using Docker and Docker Compose, orchestrated by Jenkins.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    JENKINS (CI/CD)                          │
│  - Builds application                                       │
│  - Runs tests                                              │
│  - Builds Docker image                                     │
│  - Deploys with Docker Compose                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  DOCKER COMPOSE STACK                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Spring Boot App (school_app)                        │  │
│  │  - Port: 8080                                        │  │
│  │  - Context: /school                                 │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  MySQL Database (school_db)                          │  │
│  │  - Port: 3306                                        │  │
│  │  - User: school_user                                │  │
│  │  - Database: school_db                              │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Nexus Repository (school_nexus)                    │  │
│  │  - Port: 8081                                        │  │
│  │  - Artifact storage                                 │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Files Included

### 1. **Dockerfile** - Multi-stage build
- **Stage 1**: Maven builder container (compiles code)
- **Stage 2**: Lightweight runtime (contains only JAR)
- **Benefits**: Smaller image size, better security, optimized for production

### 2. **docker-compose.yml** - Infrastructure as Code
- Defines all services: app, MySQL, Nexus
- Manages networking between services
- Handles health checks and dependencies
- Persistent data volumes

### 3. **application.properties** - Environment-aware config
- Uses environment variables with defaults
- Connects to `mysql` service instead of `localhost`
- Configurable port and context path
- Actuator endpoints for health checks

### 4. **.dockerignore** - Build optimization
- Excludes unnecessary files from Docker build context
- Reduces build time and image size

### 5. **Jenkinsfile** - Enhanced with Docker stages
- New stages: Build Docker Image, Docker Compose Deploy, Health Check
- Integrated into existing pipeline

---

## Quick Start (Local Development)

### Prerequisites
```bash
# Install Docker
# Install Docker Compose
# Install Git
```

### Step 1: Clone and Navigate
```bash
git clone https://github.com/sirinetrabelsi/school.git
cd school/school
```

### Step 2: Build and Start Services
```bash
# Build Docker image and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### Step 3: Access Services
- **Application**: http://localhost:8080/school
- **MySQL**: localhost:3306
  - Username: `school_user`
  - Password: `school_password`
  - Database: `school_db`
- **Nexus**: http://localhost:8081/nexus

### Step 4: Stop Services
```bash
docker-compose down
```

---

## Jenkins Integration

### Pipeline Stages (with Docker)

1. **Git Checkout** ✓
   - Clones repository from GitHub

2. **Build & Compile** ✓
   - Maven clean package

3. **SonarQube Analysis** ✓
   - Code quality checks

4. **JUnit & Mockito Tests** ✓
   - Unit test execution

5. **Deploy to Nexus** ✓
   - Artifacts to repository

6. **Build Docker Image** (NEW)
   - Multi-stage Docker build
   - Tags with version and latest

7. **Docker Compose Deploy** (NEW)
   - Stops existing stack
   - Builds and starts new services
   - Waits for health checks

8. **Health Check** (NEW)
   - Verifies app is responding
   - Checks database connectivity

---

## Configuration Details

### Environment Variables (application.properties)

```properties
# Database
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/school_db
SPRING_DATASOURCE_USERNAME=school_user
SPRING_DATASOURCE_PASSWORD=school_password

# Server
SERVER_PORT=8080
SERVER_SERVLET_CONTEXT_PATH=/school

# JPA/Hibernate
SPRING_JPA_HIBERNATE_DDL_AUTO=update
```

**Note**: These values are set in `docker-compose.yml` environment section.

### Docker Compose Services

#### MySQL Service
```yaml
mysql:
  image: mysql:8.0
  environment:
    MYSQL_DATABASE: school_db
    MYSQL_USER: school_user
    MYSQL_PASSWORD: school_password
  ports:
    - "3306:3306"
  volumes:
    - mysql_data:/var/lib/mysql
  healthcheck: Database health monitoring
```

#### Spring Boot App Service
```yaml
app:
  build: Dockerfile
  environment:
    SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/school_db
  ports:
    - "8080:8080"
  depends_on:
    mysql:
      condition: service_healthy
  healthcheck: App health checks via actuator
```

#### Nexus Service
```yaml
nexus:
  image: sonatype/nexus3:latest
  ports:
    - "8081:8081"
  volumes:
    - nexus_data:/nexus-data
```

---

## Dockerfile Stages

### Stage 1: Builder
```dockerfile
FROM maven:3.9.0-eclipse-temurin-17 AS builder
# Compiles code into JAR
# Result: school-1.0.0.jar
```

### Stage 2: Runtime
```dockerfile
FROM eclipse-temurin:17-jre-jammy
# Contains only JRE and JAR
# Non-root user for security
# Health checks configured
```

**Image Size Optimization**:
- With full JDK: ~600MB
- With only JRE: ~200-250MB (60% reduction)

---

## Common Commands

### Docker Compose

```bash
# Start services in background
docker-compose up -d --build

# View logs
docker-compose logs -f app
docker-compose logs -f mysql

# Stop services
docker-compose stop

# Remove services and volumes
docker-compose down -v

# Restart a service
docker-compose restart app

# View service status
docker-compose ps

# Execute command in container
docker-compose exec app bash
docker-compose exec mysql mysql -u school_user -p school_db
```

### Docker

```bash
# Build image
docker build -t school:1.0.0 .

# View images
docker images

# Remove image
docker rmi school:1.0.0

# View running containers
docker ps

# View all containers
docker ps -a

# Stop container
docker stop school_app

# Remove container
docker rm school_app

# View logs
docker logs -f school_app

# Check container stats
docker stats school_app
```

---

## Troubleshooting

### Issue: "Port 8080 already in use"
```bash
# Find process using port
lsof -i :8080

# Kill process (Linux/Mac)
kill -9 <PID>

# Or use different port in docker-compose.yml
ports:
  - "8081:8080"
```

### Issue: "MySQL connection refused"
```bash
# Check MySQL is running
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Ensure app waits for MySQL
# (Already configured with healthcheck)
```

### Issue: "Out of memory"
```bash
# Increase Docker memory
# Settings → Resources → Memory: 4GB+

# Or configure in docker-compose
services:
  app:
    deploy:
      resources:
        limits:
          memory: 2G
```

### Issue: "Application won't start"
```bash
# Check app logs
docker-compose logs app

# Check if port conflict
docker ps | grep 8080

# Verify database connection
docker-compose exec app curl http://localhost:8080/school/actuator/health
```

### Issue: "Database credentials not working"
```bash
# Verify credentials in docker-compose.yml
# Match MYSQL_USER, MYSQL_PASSWORD with SPRING_DATASOURCE_USERNAME, PASSWORD

# Restart containers
docker-compose restart
```

---

## Production Deployment

### Recommended Changes for Production

1. **Use Docker Registry (not local)**
   ```groovy
   DOCKER_REGISTRY = 'myregistry.azurecr.io'
   DOCKER_IMAGE_NAME = 'mycompany/school'
   ```

2. **Push to Registry in Jenkinsfile**
   ```groovy
   stage('Push Docker Image') {
       sh '''
           docker tag school:latest ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
           docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
       '''
   }
   ```

3. **Use External Database** (not Docker)
   - Connect to managed database (AWS RDS, Azure Database)
   - Better backup and recovery

4. **Enable Docker Registry Authentication**
   ```yaml
   services:
     app:
       image: myregistry.azurecr.io/school:latest
       imagePullSecrets:
         - name: regcred
   ```

5. **Add Resource Limits**
   ```yaml
   services:
     app:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 2G
           reservations:
             cpus: '1'
             memory: 1G
   ```

6. **Setup Backup Strategy**
   ```bash
   # Backup MySQL data
   docker-compose exec mysql mysqldump -u root -p school_db > backup.sql

   # Backup volumes
   docker run --rm -v mysql_data:/data -v $(pwd):/backup \
     alpine tar czf /backup/mysql_backup.tar.gz -C /data .
   ```

---

## Monitoring & Logging

### View Application Logs
```bash
# Real-time logs
docker-compose logs -f app

# Last 100 lines
docker-compose logs -n 100 app

# With timestamps
docker-compose logs -f -t app
```

### Health Check Endpoints
```bash
# Application health
curl http://localhost:8080/school/actuator/health

# Detailed info
curl http://localhost:8080/school/actuator/info

# Database status
curl http://localhost:8080/school/actuator/health/db
```

### Container Metrics
```bash
# Real-time resource usage
docker stats school_app

# Detailed container info
docker inspect school_app
```

---

## Security Best Practices

1. **Non-root User**
   - Dockerfile runs as `appuser` (uid: 1000)
   - Not recommended to run as root

2. **Minimal Base Images**
   - Uses `eclipse-temurin:17-jre-jammy` (small, updated)
   - Reduces attack surface

3. **Environment Variables**
   - Sensitive data in environment, not hardcoded
   - Store passwords in Jenkins Secrets

4. **Network Isolation**
   - Services connected via `school_network` bridge
   - Only exposed ports accessible externally

5. **Health Checks**
   - Containers verified before being considered healthy
   - Automatic restart on failure

---

## Next Steps

1. ✅ Run locally with Docker Compose
2. ✅ Configure Jenkins with Docker support
3. ✅ Setup Docker Registry (optional)
4. ✅ Add deployment monitoring
5. ✅ Configure log aggregation (ELK stack)

---

## Quick Reference

| Component | Port | URL | Credentials |
|-----------|------|-----|-------------|
| Application | 8080 | http://localhost:8080/school | N/A |
| MySQL | 3306 | localhost:3306 | school_user / school_password |
| Nexus | 8081 | http://localhost:8081/nexus | admin / admin |

---

## Useful Links

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Spring Boot Docker Support](https://spring.io/guides/gs/spring-boot-docker/)
- [Maven in Docker](https://hub.docker.com/_/maven)
