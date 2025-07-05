# Initial Setup: Bootstrapping the Atlantis Server

This guide provides the step-by-step instructions to provision the foundational infrastructure for our GitOps workflow. This is a one-time setup that deploys a Google Compute Engine (GCE) instance and runs the Atlantis container on it.

## Phase 1: Prerequisites (Local Machine)

Before running any code, complete these manual setup steps.

### 1. GitHub Account
You will need a GitHub account to manage the repository and create the necessary credentials for Atlantis. If you don't have one, you can [sign up for free](https://github.com/join).

### 2. GCP Project and Service Account
1.  **Create a GCP Project:** If you don't have one, create a new project in the Google Cloud Console.
2.  **Create a Service Account:**
    *   Navigate to **IAM & Admin** -> **Service Accounts**.
    *   Click **Create Service Account**. Name it something descriptive, like `atlantis-bootstrap-sa`.
    *   Grant it the following roles, which are necessary for creating the VM and its related resources:
        *   `Compute Admin`
        *   `Service Account User`
    *   Create a JSON key for this service account and download it. **Store this file securely.**

### 3. Generate GitHub Credentials
1.  **Create a Personal Access Token (PAT):** Atlantis uses this token to interact with your repository (e.g., post comments on Pull Requests).
    *   Go to your GitHub **Developer settings** -> **Personal access tokens** -> **Tokens (classic)**. (Direct Link)
    *   Give it a descriptive name (e.g., `atlantis-token`).
    *   Set an expiration date (e.g., 90 days).
    *   Select the following scopes:
        *   `repo`: Full control of private repositories.
        *   `workflow`: Required for Atlantis to update PR statuses.
    *   Click **Generate token** and **copy the token immediately**. You will not be able to see it again.

2.  **Generate a Webhook Secret:** This secret secures the communication between GitHub and your Atlantis server.
    *   Generate a strong, random string. You can use a password manager or a command-line tool:
      ```bash
      openssl rand -hex 20
      ```
    *   Save this secret alongside your GitHub PAT.

## Phase 2: Provision the Server (Local Machine)

This step uses Terraform to create the GCE VM, a persistent disk, and the necessary firewall rules.

1.  **Authenticate with GCP:**
    ```bash
    gcloud auth application-default login
    ```
2.  **Prepare Terraform Variables:**
    *   Navigate to the `Initial-setup` directory.
    *   Create a `terraform.tfvars` file (you can copy `terraform.tfvars.example` if one exists).
    *   Fill in the required variables, such as your `project_id` and `region`.
3.  **Run Terraform:**
    ```bash
    cd Initial-setup
    terraform init
    terraform plan -var-file="terraform.tfvars"
    terraform apply -var-file="terraform.tfvars"
    ```
4.  **Get the Server's Public IP:** After the apply is complete, Terraform will output the public IP address of the new VM. Note this down.

## Phase 3: Configure and Launch Atlantis (On the VM)

Now, you will connect to the newly created server to configure and start the Atlantis container.

1.  **SSH into the VM:**
    ```bash
    gcloud compute ssh atlantis-instance --zone <YOUR_VM_ZONE>
    ```
2.  **Clone the Repository:**
    ```bash
    git clone https://github.com/<your-org>/<repo-name>.git
    cd <repo-name>/Initial-setup/
    ```
3.  **Create the `.env` file:** This file securely provides secrets to the Atlantis container. Create a new file named `.env` in the `Initial-setup` directory.
    ```bash
    nano .env
    ```
    Add the following content, replacing the placeholder values with your actual credentials.
    ```dotenv
    # Environment variables for the Atlantis container
    ATLANTIS_GH_USER=<your-github-username>
    ATLANTIS_GH_TOKEN=<paste-your-github-pat-here>
    ATLANTIS_GH_WEBHOOK_SECRET=<paste-your-webhook-secret-here>
    ATLANTIS_REPO_ALLOWLIST=github.com/<your-org>/<repo-name>
    ```
4.  **Add User to Docker Group (Recommended):** This allows you to run `docker` commands without `sudo`.
    ```bash
    sudo usermod -aG docker $USER
    ```
    **Important:** You must log out and log back in for this change to take effect.

5.  **Start Atlantis:** Use Docker Compose to start the container in the background. It will automatically use the `docker-compose.yml` and the `.env` file from the current directory.
    ```bash
    # If you skipped step 4, you must use sudo
    docker-compose up -d
    ```
6.  **Verify Atlantis is Running:**
    ```bash
    # Check that the container is up and running
    docker ps

    # Check that the Atlantis UI is responding locally on the server
    curl http://localhost:4141
    ```

## Phase 4: Finalize GitHub Webhook

The final step is to tell GitHub where to send events.

1.  Navigate to your repository on GitHub: **Settings** -> **Webhooks** -> **Add webhook**.
2.  **Payload URL:** `http://<YOUR_VM_PUBLIC_IP>:4141/events`
3.  **Content type:** `application/json`
4.  **Secret:** Paste the same webhook secret you used in the `.env` file.
5.  **Which events would you like to trigger this webhook?** Select "Send me everything" or choose individual events: `Issue comments`, `Pull requests`, and `Pushes`.
6.  Click **Add webhook**. You should see a green checkmark next to it, indicating a successful delivery.

✅ **Your Atlantis setup is now complete!**
