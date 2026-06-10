Brain Tasks App - AWS DevOps Deployment
Project Overview

This project demonstrates the deployment of the Brain Tasks App using AWS DevOps services and Kubernetes. The application was containerized using Docker, stored in Amazon ECR, deployed to Amazon EKS, and automated through AWS CodeBuild and CodePipeline.

Architecture

GitHub Repository → AWS CodePipeline → AWS CodeBuild → Amazon ECR → Amazon EKS → LoadBalancer Service

Technologies Used
AWS EC2
Docker
Amazon ECR
Amazon EKS
Kubernetes
Terraform
AWS CodeBuild
AWS CodePipeline
Amazon CloudWatch
GitHub
Git
Application Source

Repository Used:

https://github.com/Vennilavanguvi/Brain-Tasks-App.git

Dockerization

The application repository contained a pre-built Vite distribution package.

Dockerfile used:

FROM public.ecr.aws/nginx/nginx:alpine

COPY dist/ /usr/share/nginx/html

EXPOSE 80

Docker image was built and tested locally before deployment.

Commands used:

docker build -t brain-task-app:latest .
docker run -d -p 3000:80 brain-task-app:latest
Amazon ECR

ECR Repository:

645437362580.dkr.ecr.ap-south-1.amazonaws.com/brain-task-app

Commands used:

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 645437362580.dkr.ecr.ap-south-1.amazonaws.com

docker tag brain-task-app:latest 645437362580.dkr.ecr.ap-south-1.amazonaws.com/brain-task-app:latest

docker push 645437362580.dkr.ecr.ap-south-1.amazonaws.com/brain-task-app:latest
Infrastructure Provisioning using Terraform

Terraform was used to create:

VPC
Public Subnets
Private Subnets
NAT Gateway
EKS Cluster
EKS Managed Node Group

Terraform Commands:

terraform init
terraform plan
terraform apply

EKS Cluster Name:

brain-eks

Cluster Version:

1.30

Node Group Configuration:

Desired Capacity : 2
Instance Type    : t3.medium
Kubernetes Deployment

Deployment manifest created:

k8s/deployment.yaml

Service manifest created:

k8s/service.yaml

Deployment Commands:

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

Verification Commands:

kubectl get nodes
kubectl get pods
kubectl get svc
CodeBuild

CodeBuild Project was configured to:

Authenticate with Amazon ECR
Build Docker Image
Push Image to ECR
Deploy Kubernetes Resources to EKS

Buildspec file:

buildspec.yml

Build Process:

docker build
docker tag
docker push
kubectl apply
CodePipeline

Pipeline Name:

brain-task-pipeline

Pipeline Stages:

Source Stage (GitHub)
Build Stage (AWS CodeBuild)
Deploy Stage (EKS Deployment)

Pipeline Execution was successfully triggered using:

aws codepipeline start-pipeline-execution --name brain-task-pipeline
EKS Authentication Configuration

The CodeBuild IAM Role was mapped into EKS RBAC using aws-auth ConfigMap.

Role Added:

arn:aws:iam::645437362580:role/CodeBuildBrainRole

Permission Granted:

system:masters

This enabled CodeBuild to execute kubectl commands against the EKS cluster.

Monitoring

Amazon CloudWatch was used to monitor:

CodeBuild Logs
EKS Control Plane Logs
Kubernetes Pod Logs

Verification Commands:

kubectl logs <pod-name>

CloudWatch Log Sources:

/aws/codebuild/*
/aws/eks/brain-eks/cluster
Repository Structure
project-final/
│
├── app/
│   ├── dist/
│   ├── Dockerfile
│   └── README.md
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── terraform/
│   └── main.tf
│
├── buildspec.yml
└── .gitignore
Validation Commands

Docker:

docker images
docker ps

Kubernetes:

kubectl get nodes
kubectl get pods
kubectl get svc

EKS:

aws eks describe-cluster --name brain-eks

Pipeline:

aws codepipeline start-pipeline-execution --name brain-task-pipeline
Outcome

Successfully completed:

Application Deployment
Dockerization
Amazon ECR Integration
Terraform Infrastructure Provisioning
Amazon EKS Cluster Setup
Kubernetes Deployment
AWS CodeBuild Automation
AWS CodePipeline Automation
CloudWatch Monitoring Integration

The application was successfully deployed on Amazon EKS and managed through a CI/CD pipeline using AWS native DevOps services.
