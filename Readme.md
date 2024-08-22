
# Jenkins Kubernetes Project

This project sets up a Jenkins instance within a Kubernetes environment using a custom Jenkins Docker image. The Jenkins instance is configured to interact with Docker through a Docker-in-Docker (DinD) setup, enabling it to run Docker commands and build Docker images. The project also utilizes Kubernetes secrets and persistent volumes to manage Jenkins configurations and Docker certificates securely.

## Project Structure

- **Dockerfile**: Builds a custom Jenkins Docker image with Docker CLI, `kubectl`, and Jenkins plugins.
- **plugins.txt**: Lists Jenkins plugins to be installed in the custom Jenkins image.
- **seed-job.groovy**: A Groovy script that automatically sets up a Jenkins pipeline job for a specified Git repository.
- **jenkins-data-pvc.yaml**: Defines a PersistentVolumeClaim for Jenkins data storage.
- **jenkins-docker-certs-pvc.yaml**: Defines a PersistentVolumeClaim for storing Docker certificates.
- **docker-deployment.yaml**: Deploys a Docker-in-Docker (DinD) container in the Kubernetes cluster.
- **jenkins-deployment.yaml**: Deploys the custom Jenkins instance in the Kubernetes cluster, linking it with Docker-in-Docker and Kubernetes secrets.
- **run-kubectl.bat**: A batch script that automates the process of building and pushing the custom Jenkins Docker image and deploying the entire setup to a Kubernetes cluster. When this file is run, it will ask for the Docker Hub username and password (or token) as well as the Kubernetes namespace.


## Prerequisites

- A running Kubernetes cluster (tested with Minikube).
- Docker installed on your local machine.
- Access to a Docker Hub account for pushing the custom Jenkins image.
- **Kubeconfig File and Certificates:**
  - Copy your kubeconfig file from your local machine to the current directory:
  - Copy the following certificates from your Minikube directory to the current directory:
    - `ca.crt`
    - `client.crt`
    - `client.key`

### Updating Kubeconfig File Paths

1. **Open the `kubeconfig` file** in a text editor.
2. **Update the paths** for `certificate-authority`, `client-certificate`, and `client-key` to reflect the local files you copied into the current directory. 

   For example, update the kubeconfig entries to:
   ```yaml
   certificate-authority: /tmp/ca.crt
   client-certificate: /tmp/client.crt
   client-key: /tmp/client.key

## Setup Instructions

### 1. Build and Push Custom Jenkins Image

Run the `run-kubectl.bat` script to build the custom Jenkins Docker image and push it to Docker Hub. This script will:

1. Log in to Docker Hub.
2. Build the Docker image if it doesn't already exist.
3. Push the Docker image to Docker Hub.

### 2. Deploy Jenkins and Docker in Kubernetes

The same `run-kubectl.bat` script will also:

1. Check if the specified Kubernetes namespace exists, creating it if necessary.
2. Create the Kubernetes secret for the Jenkins kubeconfig.
3. Apply the PersistentVolumeClaims for Jenkins data and Docker certificates.
4. Deploy the Docker-in-Docker container.
5. Deploy the Jenkins instance.

### 3. Access Jenkins

Once deployed, Jenkins will be accessible via a NodePort service. To get the Jenkins URL:

```bash
minikube service jenkins --url -n <your-namespace>
```

### 4. Configure Jenkins

The custom Jenkins image skips the initial setup wizard and pre-installs the necessary plugins. The Groovy script `seed-job.groovy` automatically sets up a pipeline job for the specified Git repository.

### 5. Cleanup

To remove all resources, you can delete the namespace:

```bash
kubectl delete namespace <your-namespace>
```

Replace `<your-namespace>` with the actual namespace you used during deployment.

## Files Overview

### Dockerfile

This Dockerfile starts from the official Jenkins LTS image and adds:

- Docker CLI for interacting with Docker.
- `kubectl` for interacting with Kubernetes clusters.
- Necessary Jenkins plugins.
- A Groovy script for setting up an initial pipeline job.

### plugins.txt

This file lists the Jenkins plugins to be installed during the Docker image build process.

### seed-job.groovy

This script is used to automatically create a Jenkins pipeline job in a specified folder. The pipeline pulls the Jenkinsfile from a Git repository, enabling CI/CD right out of the box.

### jenkins-data-pvc.yaml

Defines a PersistentVolumeClaim to persist Jenkins data across pod restarts.

### jenkins-docker-certs-pvc.yaml

Defines a PersistentVolumeClaim to store Docker certificates required by Jenkins to securely interact with Docker-in-Docker.

### docker-deployment.yaml

This Kubernetes deployment runs a Docker-in-Docker container, which Jenkins uses to build Docker images.

### jenkins-deployment.yaml

This Kubernetes deployment runs the custom Jenkins image, connecting it with Docker-in-Docker and managing Jenkins configurations through Kubernetes secrets.

### run-kubectl.bat

A Windows batch script that automates the entire process from building the Docker image to deploying the Kubernetes resources.

## Notes

- This setup is designed for a development environment, particularly for learning and testing CI/CD workflows with Jenkins in Kubernetes.
- Ensure that your Kubernetes cluster has sufficient resources to run both Jenkins and Docker-in-Docker.
- Consider security implications when running Docker-in-Docker in production environments.

## Troubleshooting

- **Jenkins Fails to Start**: Check the logs of the Jenkins pod for any errors.
- **Docker Commands Fail in Jenkins**: Ensure that the Docker-in-Docker service is up and running, and that Jenkins is correctly configured to use it.
- **Kubernetes Resources Not Applied**: Verify that your Kubernetes context is set correctly and that you have sufficient permissions.
