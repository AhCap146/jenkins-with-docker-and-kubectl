@echo off
setlocal

REM Docker Hub username and password
set /p DOCKER_USERNAME="Enter Docker Hub username: "
set /p DOCKER_PASSWORD="Enter Docker Hub password or token: "

REM Kubernetes namespace
set /p KUBE_NAMESPACE="Enter Kubernetes namespace: "

REM Define Docker image variables
set DOCKER_IMAGE_NAME=%DOCKER_USERNAME%/custom-jenkins
set DOCKER_IMAGE_TAG=latest
set DOCKER_REPO_URL=docker.io
set DOCKERFILE_PATH=jenkins-image-with-groovy-script

REM Log in to Docker Hub securely
echo Logging in to Docker Hub...
docker logout
docker login %DOCKER_REPO_URL% -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%
if %ERRORLEVEL% neq 0 (
    echo Docker login failed. Please check your credentials.
    exit /b %ERRORLEVEL%
)

REM Check if the Docker image already exists
echo Checking if Docker image %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% exists...
docker manifest inspect %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Docker image not found. Building Docker image...
    
    REM Build the Docker image
    docker build -t %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% -f %DOCKERFILE_PATH%/Dockerfile %DOCKERFILE_PATH%

    REM Push the Docker image to Docker Hub
    echo Pushing Docker image to Docker Hub...
    docker push %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%
) else (
    echo Docker image %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% already exists on Docker Hub. Skipping build and push.
)

REM Check if the namespace 'jenkins' exists
kubectl get namespace %KUBE_NAMESPACE% >nul 2>&1

REM If the namespace doesn't exist, create it
if %ERRORLEVEL% neq 0 (
    echo Namespace '%KUBE_NAMESPACE%' does not exist. Creating it...
    kubectl create namespace %KUBE_NAMESPACE%
) else (
    echo Namespace '%KUBE_NAMESPACE%' already exists.
)

REM Apply the Kubernetes configurations
kubectl create secret generic jenkins-kubeconfig --from-file=config=config -n %KUBE_NAMESPACE%
kubectl apply -f jenkins-data-pvc.yaml -n %KUBE_NAMESPACE%
kubectl apply -f jenkins-docker-certs-pvc.yaml -n %KUBE_NAMESPACE%
kubectl apply -f docker-deployment.yaml -n %KUBE_NAMESPACE%
kubectl apply -f jenkins-deployment.yaml -n %KUBE_NAMESPACE%

pause
