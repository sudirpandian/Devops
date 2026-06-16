<<<<<<< HEAD
# Devops
Tasks
=======
# DevOps Build — React App Deployment

A production-ready containerized React app deployed via Docker, Jenkins CI/CD, and AWS EC2.

---

## 📁 Project Structure
```
devops-build/
├── build/                  # Pre-built React static files
├── monitoring/
│   ├── docker-compose.monitoring.yml
│   ├── setup-monitoring.sh
│   └── README-monitoring.md
├── screenshots/            # Submission screenshots (add here)
├── Dockerfile              # Nginx-based production image
├── docker-compose.yml      # App deployment compose file
├── nginx.conf              # Nginx reverse proxy config
├── build.sh                # Docker build & push script
├── deploy.sh               # Docker deploy script
├── Jenkinsfile             # CI/CD pipeline definition
├── .dockerignore
└── .gitignore
```

---

## 🐳 Docker

### Build image locally
```bash
# Dev build
./build.sh dev YOUR_DOCKERHUB_USERNAME

# Prod build
./build.sh master YOUR_DOCKERHUB_USERNAME
```

### Deploy
```bash
./deploy.sh YOUR_DOCKERHUB_USERNAME/dev:latest
```

### App runs on → http://localhost:80

---

## ⚙️ Jenkins Setup

### 1. Install Jenkins on EC2
```bash
sudo apt update
sudo apt install -y openjdk-17-jre curl

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update && sudo apt install -y jenkins
sudo systemctl start jenkins && sudo systemctl enable jenkins
```

### 2. Install Docker on EC2
```bash
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart jenkins
```

### 3. Jenkins Credentials to Add
Go to: `Manage Jenkins → Credentials → Global`

| ID | Type | Value |
|----|------|-------|
| `DOCKER_HUB_USERNAME` | Secret text | Your Docker Hub username |
| `DOCKER_HUB_PASSWORD` | Secret text | Your Docker Hub password |

### 4. Create Jenkins Pipeline Job
1. New Item → Pipeline
2. Name: `devops-build`
3. Check: **GitHub Project** → enter repo URL
4. Build Triggers: ✅ **GitHub hook trigger for GITScm polling**
5. Pipeline: **Pipeline script from SCM**
   - SCM: Git
   - Repo URL: `https://github.com/YOUR_USERNAME/devops-build`
   - Branches: `*/dev` and `*/master`
   - Script Path: `Jenkinsfile`

### 5. GitHub Webhook
Go to GitHub repo → Settings → Webhooks → Add webhook:
- Payload URL: `http://YOUR-EC2-IP:8080/github-webhook/`
- Content type: `application/json`
- Events: **Just the push event**

---

## ☁️ AWS EC2 Setup

### Launch Instance
- AMI: Ubuntu 22.04 LTS
- Type: t2.micro
- Key Pair: create/select existing

### Security Group Rules

| Type | Port | Source | Purpose |
|------|------|--------|---------|
| HTTP | 80 | 0.0.0.0/0 | App access (everyone) |
| Custom TCP | 8080 | 0.0.0.0/0 | Jenkins UI |
| Custom TCP | 3001 | Your IP/32 | Uptime Kuma dashboard |
| SSH | 22 | Your IP/32 | SSH login (your IP only) |

---

## 🐋 Docker Hub Repos

| Repo | Visibility | Image |
|------|-----------|-------|
| `YOUR_USERNAME/dev` | Public | Dev branch builds |
| `YOUR_USERNAME/prod` | Private | Master branch builds |

---

## 📊 Monitoring

```bash
cd monitoring/
./setup-monitoring.sh
# Open: http://YOUR-SERVER-IP:3001
```

See [monitoring/README-monitoring.md](monitoring/README-monitoring.md) for full setup.

---

## 🔁 CI/CD Flow

```
Push to dev branch
    → Jenkins triggers
    → docker build
    → push to DockerHub /dev repo
    → deploy on server

Merge dev → master
    → Jenkins triggers
    → docker build
    → push to DockerHub /prod repo (private)
    → deploy on server
```

---

## 📸 Screenshots (add to /screenshots folder)
- [ ] Jenkins login page
- [ ] Jenkins pipeline configuration
- [ ] Jenkins build execute step / console output
- [ ] AWS EC2 Console
- [ ] AWS Security Group config
- [ ] Docker Hub repos with image tags
- [ ] Deployed site page (http://YOUR-SERVER-IP)
- [ ] Uptime Kuma monitoring health status

---

## 🔗 Submission Links
- **GitHub Repo**: `https://github.com/YOUR_USERNAME/devops-build`
- **Deployed Site**: `http://YOUR-EC2-IP/`
- **Dev Docker Image**: `YOUR_USERNAME/dev:latest`
- **Prod Docker Image**: `YOUR_USERNAME/prod:latest` (private)
>>>>>>> 5422bec (production deployment setup)
# test
