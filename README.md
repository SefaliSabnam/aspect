# Kubernetes CI/CD App with Jenkins, Prometheus, Grafana, and PostgreSQL

## Overview
A complete pipeline demonstrating CI/CD using Jenkins with a Minikube Kubernetes cluster including monitoring and visualization.

## Features
- CRUD backend in Flask
- PostgreSQL with persistent volume
- Jenkins CI/CD on GitHub merge to main
- Prometheus for metrics
- Grafana dashboards
- Secure secrets handling for credentials

## Requirements
- Docker, kubectl, Minikube, Jenkins, Git, Helm

## Steps
1. Clone repo and configure credentials
2. Run `minikube start`
3. Deploy Kubernetes manifests from `k8s/`
4. Setup Jenkins pipeline using `Jenkinsfile`

## Author
Sefali