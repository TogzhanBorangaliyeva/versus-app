# Versus Application Deployment Guide

## Overview

This document serves as a **comprehensive guide** for deploying the Versus application. It summarizes the key steps and configurations required to successfully deploy and manage the application in a **Kubernetes environment**.

This application is deployed using a **GitLab CI/CD pipeline** on a **self-hosted GitLab Runner** registered on EC2 Instance. The CI/CD job handles building and deploying both the **frontend and backend services** using **Docker and Helm**.

---

## ✅ Prerequisites

Ensure you have the following:

        **AWS EKS Cluster**: A functional Kubernetes cluster.

- **AWS Secrets Manager**: Configured with database credentials.
- **AWS IAM Role and Policies**: Permissions granted for Secrets Manager access.
- **GitLab Repository & CI/CD Access**: For managing deployments.
- **SSL/TLS Certificates**: Required for secure ingress.
- **AWS Elastic Container Registry (ECR)**.

---

## Pre Deployment Steps

### 1. Installing the CSI Driver and AWS Provider

Before creating the service account, install the **Secrets Store CSI Driver** and AWS Provider to link **AWS Secrets Manager** with **Kubernetes Secrets**.

🔗 **Reference Links:**

- [Secrets Store CSI Driver Guide](https://github.com/312school/aws-secrets-sync-with-k8s/tree/main)
- [AWS CSI Driver Documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html)

---

### 2. Configuring TLS Certificates

For ingress to have valid TSL certificates, the TSL certificate secret must be deployed to the cluster and placed in the correct namespace.

📌 **Reference Links:**

- [Certbot (Recommended ACME Client)](https://certbot.eff.org/)
- [Using Let's Encrypt with Kubernetes (Cert-Manager)](https://cert-manager.io/docs/)

---

### 3. Backend Database Connection

The backend connects to the database using credentials stored in AWS Secrets Manager. These credentials are fetched using the **Kubernetes Secrets Store CSI Driver**. The necessary environment variables include:

- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`

---

### 4. Database Migration and Data Loading

The backend application includes an `entrypoint.sh` script to handle database migrations and initial data loading automatically.The script performs the following actions:

1. Run database migrations:
    
    ```
    python manage.py migrate
    
    ```
    
2. Load initial data from `data.json`:
    
    ```
    python manage.py loaddata /backend/api/fixtures/data.json
    
    ```
    

---

### 5. Frontend Interaction with Backend

The frontend application interacts with the backend through the `REACT_APP_API_URL` environment variable, which is provided to the frontend pod during deployment. This variable specifies the backend API endpoint used by the frontend to communicate with the backend.

The API URL is dynamically set in the frontend's environment configuration to ensure proper connectivity between frontend and backend components. The setup ensures that API calls from the frontend are routed correctly to the backend service in the Kubernetes cluster.

If the backend is exposed through an Ingress, ensure that the `REACT_APP_API_URL` matches the externally accessible API endpoint. This is essential for frontend applications running outside the cluster to interact with the backend services.

---

## Deployment Process

### CI/CD Pipeline Workflow

1. The **GitLab Runner job** triggers deployment.
2. A pod is dynamically created by the runner.
3. The job **builds the frontend and backend Docker images**.
4. The images are **pushed to AWS Elastic Container Registry (ECR)**.
5. After image push, **Helm is used to deploy the application** to the Kubernetes cluster.

---

### Prerequisites for the GitLab Runner (running as `gitlab-runner` user)

- Ensure that the `gitlab-runner` user has **read access** to the `/home/ubuntu/.kube/config` file
- Ensure the GitLab **CI/CD role has the necessary permissions** inside the cluster to deploy via Helm.
- In the `.gitlab-ci.yml`, you can configure environment variables to pass the kubeconfig file location, or you can mount the `kubeconfig` as a secret or volume if needed

---

### Configuration

- Set up values in the `/app-helm-chart/values` directory.
- **Templates for backend production values and frontend production values are already provided.**

---

  **Job Completion**

- If the job completes successfully, it returns:
**`App deployed successfully`**

---

### Notes

- Ensure the correct namespace is used for all commands.
- If you encounter issues with Secrets Manager access, verify the IAM role attached to the service account and its associated policies.
- Regularly update and manage SSL certificates to maintain secure communication.

---

## **Summary of Common Issues and Fixes**

| Issue | Cause | Solution |
| --- | --- | --- |
| exec /docker-entrypoint.sh: exec format error | Mismatched architecture (e.g., using an ARM image on an x86 node). Docker image for frontend is works on architecture : "arm64” | Restarting machine and reinstall docker  |
| Job pod fails due to insufficient resources | Resource requests and limits are not set correctly | Ensure the runner and job pod have appropriate CPU/memory requests and limits set |
| Docker build fails due to lack of storage | The node does not have enough ephemeral storage | Allocate sufficient storage for the job pod and runner node |
| Job pod gets scheduled on a different node than the runner | Kubernetes scheduler dynamically assigns a different node | Ensure node affinity settings are configured properly if required |
| GitLab Runner fails to authenticate with ECR | Missing IAM permissions for the runner | Verify that the runner’s IAM role has the necessary permissions to authenticate with AWS ECR |
| Helm deployment fails due to missing values | Configuration files are not set up properly | Ensure that `/app-helm-chart/values` directory contains the necessary values files |
| Job completes but deployment does not update | Cached Helm release prevents update | Use `helm upgrade --install` with `--force` to override any existing deployment |