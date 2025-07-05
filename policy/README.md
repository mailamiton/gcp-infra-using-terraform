
# 🛡️ Conftest Policies for Terraform (Enterprise Standards)

This directory contains **OPA (Open Policy Agent)** policies written in **Rego** for enforcing best practices and security standards on Terraform infrastructure as code (IaC). These policies are used with **Conftest** and integrated into the `Atlantis` workflow.

---

## 📁 Directory Structure

```
policy/
├── bucket_policy.rego
├── labels.rego
├── service_account.rego
└── machine_type.rego
```

---

## 📜 Policy Descriptions

### ✅ `bucket_policy.rego`
- **Purpose**: Enforces that all Google Cloud Storage buckets must have `bucket_policy_only` mode enabled.
- **Why**: Prevents accidental public access via ACLs.
- **Violation Example**:
  ```
  GCS bucket must have bucket policy only mode enabled
  ```

---

### ✅ `labels.rego`
- **Purpose**: Ensures that all Terraform resources include required labels like `env` and `team`.
- **Why**: Supports cost tracking, auditing, and environment segregation.
- **Violation Example**:
  ```
  Resource missing required labels: {"env", "team"}
  ```

---

### ✅ `service_account.rego`
- **Purpose**: Disallows the use of Google Cloud default service accounts.
- **Why**: Encourages use of least-privilege custom service accounts.
- **Violation Example**:
  ```
  Using default service account is not allowed
  ```

---

### ✅ `machine_type.rego`
- **Purpose**: Enforces use of specific approved machine types (`n2-*`).
- **Why**: Ensures usage of optimized, cost-effective machine families.
- **Violation Example**:
  ```
  Only n2-* machine types are allowed. Found: e2-medium
  ```

---

## 🚀 How It Works

These policies are automatically evaluated during the `terraform plan` stage via [Atlantis](https://www.runatlantis.io/) using the [`show` + `conftest` integration](https://www.openpolicyagent.org/docs/latest/conftest/).

The `atlantis.yaml` workflow example:

```yaml
workflows:
  conftest:
    plan:
      steps:
        - init
        - plan
        - show
        - run: conftest test --all-namespaces -p policy/ -
    apply:
      steps:
        - apply
```

---

## 🧪 Testing Policies Locally

You can test policies manually with:

```bash
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
conftest test tfplan.json -p policy/
```

---

## 📌 Requirements

- Terraform v1.0+
- Conftest v0.36.0+
- Rego language basics (for policy authors)
- Terraform plan in JSON format (`terraform show -json`)

---

> ℹ️ For policy customization or adding more rules, refer to the [OPA docs](https://www.openpolicyagent.org/docs/latest/) and [Conftest](https://www.conftest.dev/).
