# Base image: Atlantis v0.34.0
FROM ghcr.io/runatlantis/atlantis:v0.34.0

# Set Terraform version
ENV TERRAFORM_VERSION=1.12.2

# Download and install Terraform
RUN curl -sSLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/terraform && \
    rm /tmp/terraform.zip

# Verify installation
RUN terraform version
