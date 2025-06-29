# gcp-infa
# Terraform Setup gcp
## Setp 1 (Manual)
  1. Create a project with Appropiate Name. 
  2. Create a service Account with Appropiate Name and Role 
       1. IAM → Create service account: terraform-deployer
            Grant roles:
            Editor or fine-grained roles like:
            1. Compute Admin
            2. Storage Admin
            3. Service Account User
       2. Generate and download JSON key. Store this key securely (you’ll mount it into Atlantis later)
  3.  Create GitHub Repo with Terraform Code with appropiate Name and Push all of this to GitHub.

## Setp 2 - Setup VM and bucket to store state
 1.  Setup bucket and VM with docker and git for atlantis using terrform code in folder initial-setup.
      ```
        cd initial-setup
        terraform plan -var-file="terraform.tfvarS"
        terraform apply -var-file="terraform.tfvars"
      ```
   2. Once the VM is setup ssh into VM and run atlantis server.
      1. SSH into VM and generate public and private key and add it git hub repo in order to clone this.
      2. Add agent using below command
        ```
         chmod 400 ~/.ssh/id_ed_25519
         eval 'ssh-agent -s
         ssh-add ~/.ssh/id_ed25519
        ```
      2. Clone the git repos  git clone git@github.com:mailamiton/gcp-infra-using-terraform.git
      3. Generate a GitHub Personal Access Token (PAT)
      🔧 Step-by-Step -
              Go to: https://github.com/settings/tokens
              Click: "Generate new token (classic)"
              Choose:
              Expiration: Recommended 30–90 days or "No expiration" (if you’re rotating it manually)
              Scope Permissions (see below 👇)
              Copy and securely store the token (you won’t see it again)
              Add it as ATLANTIS_GH_TOKEN in your Docker/Helm config
              🔐 Minimum Required Scopes (for GitHub PAT)
              Scope	Purpose
              repo	Read/write access to repos (comments, PRs, etc.)
              read:org	(If using org teams in atlantis.yaml)
              admin:repo_hook	(Only if Atlantis manages webhooks — optional)

       4. configure atalantis/docker-compose.yml with parameters required
   3. Set Up GitHub Webhook Go to 
      1. GitHub repo → Settings → Webhooks → Addwebhook:
      2. Payload URL: http://<your-server-ip>:4141/events
      3. Content type: application/json
      4. Secret: same as ATLANTIS_GH_WEBHOOK_SECRET (Random secrect generated)
      5. Events: Pull requests, Push, Issue comments
      6. To integrate Atlantis with GitHub, you need to generate a GitHub token (either a Personal Access Token or a GitHub App token) that Atlantis will use to:
        Comment on PRs
        Read PR metadata and files
        Manage webhooks (optional)
        Approve/reject PRs (optional, if allowed)
        Clone private repositories

   4. put docker-compose.yml  terraform-sa.json in location where you want to run docker compose
           for permission error - sudo usermod -aG docker $USER
           run command 
           ```
             sudo docker-compose up
           ```
            curl localhost:4141
