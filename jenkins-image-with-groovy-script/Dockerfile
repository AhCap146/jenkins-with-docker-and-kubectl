# Use the official Jenkins LTS image
FROM jenkins/jenkins:lts

# Switch to root to install Docker and Docker Compose
USER root

# Update package list and install required packages
RUN apt-get update && apt-get install -y lsb-release

# Add Docker’s official GPG key
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg

# Set up the Docker repository
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker CLI
RUN apt-get update && apt-get install -y docker-ce-cli

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
&& chmod +x kubectl \
&& mv kubectl /usr/local/bin/

# Skip the initial setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Pre-install Jenkins plugins using the Plugin Installation Manager CLI
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy Groovy scripts for Jenkins initialization
COPY seed-job.groovy /usr/share/jenkins/ref/init.groovy.d/seed-job.groovy

# Switch back to the Jenkins user
USER jenkins
