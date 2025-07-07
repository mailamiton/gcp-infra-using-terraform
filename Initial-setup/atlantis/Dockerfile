FROM ghcr.io/runatlantis/atlantis:v0.34.0

ENV TERRAFORM_VERSION=1.12.2

# Install Terraform to Atlantis-compatible path
RUN mkdir -p /home/atlantis/.atlantis/bin && \
    cd /tmp && \
    curl -fsSLO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /home/atlantis/.atlantis/bin/terraform${TERRAFORM_VERSION} && \
    chmod +x /home/atlantis/.atlantis/bin/terraform${TERRAFORM_VERSION} && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verify
RUN /home/atlantis/.atlantis/bin/terraform${TERRAFORM_VERSION} version
