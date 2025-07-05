# GCP Infrastructure Management with Terraform and Atlantis

This repository contains the Infrastructure as Code (IaC) for managing our Google Cloud Platform (GCP) resources. It uses a GitOps workflow powered by Terraform and Atlantis for automated, collaborative, and safe infrastructure changes.

The project is divided into two main components:

1.  **Initial Setup**: The bootstrap infrastructure required to run the Atlantis automation server.
2.  **Core Infrastructure**: The actual GCP resources (projects, networks, services) for our applications and teams.

---

## 🏛️ Project Structure Overview

### 1. Initial Setup (`./Initial-setup`)

This directory contains the foundational Terraform code to provision the Atlantis server itself. Think of this as the "factory" that builds our automation engine. This is a one-time, manually-applied configuration to get the system running.

**Key Responsibilities:**
*   Provisions a Google Compute Engine (GCE) VM.
*   Installs and configures Docker and Docker Compose on the VM.
*   Sets up the necessary firewall rules for Atlantis to receive webhooks from GitHub.
*   Provides the `docker-compose.yml` to run the Atlantis container.

> **➡️ For detailed instructions on bootstrapping the environment, see the Initial Setup README.** [Link](./Initial-setup/README.md)

### 2. Core Infrastructure (`./terraform`)

This directory holds the primary Terraform code for all our GCP resources. It is designed to be managed entirely through a GitOps workflow. All changes are proposed via Pull Requests, where Atlantis provides automated `terraform plan` feedback and executes `terraform apply` upon approval.

**Key Features:**
*   **Team & Environment Separation**: Code is organized by teams (`team-ops`, `team-data`) and environments (`dev`, `prod`).
*   **Shared Modules**: Reusable infrastructure components are defined in the `modules/` directory to ensure consistency and reduce code duplication.
*   **Automated Workflow**: Atlantis is configured via `atlantis.yaml` to automatically plan changes for each project when a Pull Request is opened.

> **➡️ For details on the repository structure and how to make infrastructure changes, see the Terraform Infrastructure README.** (This file should be created to document the core infra workflow).

---

## 🚀 Typical Workflow

Once the initial setup is complete, a developer making an infrastructure change follows these steps:

1.  **Create a Branch**: Create a new feature branch from `main`.
2.  **Make Changes**: Modify the Terraform code in the relevant project directory under `terraform/`.
3.  **Open a Pull Request**: Push the branch and open a PR against `main`.
4.  **Review Plan**: Atlantis automatically runs `terraform plan` and posts the output as a comment in the PR.
5.  **Get Approval**: The team reviews the code and the plan.
6.  **Apply Changes**: Once approved, a team member comments `atlantis apply` on the PR. Atlantis runs `terraform apply` and provides the output before the PR is merged.
