# Trend App - Production Deployment

## Architecture
- React app (pre-built) served via Nginx
- Containerized with Docker
- Deployed on AWS EKS (Kubernetes)
- CI/CD via Jenkins Pipeline
- Monitoring via Prometheus + Grafana

## Infrastructure (Terraform)
- AWS Default VPC
- EC2 t3.medium (Jenkins Server)
- Security Group (ports 22, 8080, 3000)
- IAM Instance Profile

## Setup Instructions

### 1. Clone Repo
git clone https://github.com/sudirpandian/Devops.git
cd Devops && git checkout project-2

### 2. Build Docker Image
docker build -t trend-app:v1 .
docker run -d -p 3000:3000 trend-app:v1

### 3. Provision Infrastructure
cd terraform
terraform init
terraform apply -auto-approve

### 4. Create EKS Cluster
eksctl create cluster --name trend-eks --region ap-south-1 \
  --nodegroup-name workers --node-type t3.medium --nodes 2 --managed

### 5. Deploy to Kubernetes
kubectl apply -f k8s/
kubectl get svc

### 6. Jenkins Pipeline
- URL: http://13.233.6.179:8080
- Pipeline: trend-pipeline
- Trigger: GitHub webhook on push to project-2

## CI/CD Pipeline Stages
1. Checkout - Pull code from GitHub
2. Docker Build - Build image with build number tag
3. Docker Push - Push to DockerHub (sudirpandian01/trend-app)
4. Deploy to EKS - Rolling update via kubectl

## Application URLs
- App LoadBalancer: acb3e287859904ca9ab80f76b50959d7-118934367.ap-south-1.elb.amazonaws.com
- Grafana: a2fbedeae40fe47a58e4697ea28bc8f9-1627958472.ap-south-1.elb.amazonaws.com

## Monitoring
- Prometheus + Grafana via kube-prometheus-stack
- Monitors cluster health, pod status, node metrics
