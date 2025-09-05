# Terraform AWS Infra Template (Portfolio Edition)

> **Purpose:** This README documents an AWS infrastructure template I built for a real client project. Sensitive values and names have been replaced with safe placeholders so the structure and approach can be showcased publicly.

---

## Overview

This repository provisions a complete, production‑grade AWS foundation using Terraform. It lays down shared networking, security, build artifacts, and service delivery primitives, and then composes per‑app stacks (admin, backend, frontend, storybook) for each environment (dev/stg/prod).

### What it sets up

* **VPC & networking:** VPC, public/private subnets across AZs, route tables, NAT, Internet Gateway, and optional Bastion host for controlled SSH access.
* **Compute & containers:** ECS/Fargate‑ready networking and IAM (service stacks live under environment folders).
* **Traffic & delivery:** Application/Network Load Balancer (as applicable) and Route 53 DNS records.
* **Artifacts:** Global Amazon ECR repository for images shared across environments.
* **Static delivery:** S3 buckets (e.g., web assets) and CloudFront distributions (defined in service stacks).
* **Email:** Amazon SES setup for transactional emails (domains/identities/records).
* **Pipelines:** CodeBuild/CodePipeline definitions per service (under environment stacks); supports CI/CD from Git.
* **Observability & ops:** IAM roles/policies, KMS keys (service stacks), and LaunchDarkly hooks (where applicable).

> **Note:** Everything is parameterised via `vars.tf` and environment‐specific `*.tfvars` files. Atlantis can be used for GitOps‑style automation.

---

## Repo structure (high level)

```
/                     # Root infrastructure
├── .atlantis.yml     # Atlantis project/workflows (optional GitOps)
├── .gitignore
├── .terraform.lock.hcl
├── bastion.tf        # Optional bastion host (SSM Session Manager or SSH)
├── clear_intent_nat_ec2.tf    # NAT instances/NAT gateways (implementation variant)
├── clear_intent_nat_routes.tf # Routing for NAT + private subnets
├── dns.tf            # Route 53 hosted zones & records
├── global_ecr.tf     # Global ECR repo (shared across envs)
├── lb.tf             # ALB/NLB & target groups/listeners
├── main.tf           # Root module composition & outputs
├── provider.tf       # Providers, versions, backend (remote state, etc.)
├── ses.tf            # SES domains, identities, and DNS records
├── vars.tf           # Input variables for the root stack
├── vpc.tf            # VPC, subnets, IGW, NAT, route tables
└── clear_intent_dev/ # Example environment with per‑service stacks
    ├── admin/        # CloudFront/S3, pipelines, IAM for Admin app
    ├── backend/      # ECS/Fargate, RDS/Redis, pipelines, IAM for Backend
    ├── frontend/     # CloudFront/S3, pipelines, IAM for Frontend
    └── storybook/    # Static site delivery & pipelines
```

*Other environments such as `clear_intent_stg` and `clear_intent_prod` follow the same pattern.*

---

## Root modules explained

* **`vpc.tf`** — Creates the base network (VPC, subnets across AZs, Internet Gateway, route tables, NAT pattern). Designed for multi‑AZ high availability and private workloads.
* **`clear_intent_nat_ec2.tf` & `clear_intent_nat_routes.tf`** — Encapsulate the NAT strategy (NAT gateways or NAT instances, depending on cost/requirements) and wire up private subnet egress.
* **`bastion.tf`** — Optional jump host for controlled access to private resources. Can be replaced with AWS SSM Session Manager.
* **`lb.tf`** — Configures an ALB/NLB, default listener rules, security groups, and target groups. Application services register here from the env stacks.
* **`dns.tf`** — Sets up Route 53 zones and records (A/AAAA/CNAME/TXT), including validation records for ACM/SES.
* **`global_ecr.tf`** — A shared ECR repository (and lifecycle) for container images used by all environments.
* **`ses.tf`** — Provisions SES identities and (optional) domain/DMARC/SPF/DKIM records for email sending.
* **`provider.tf`** — Provider pins and remote state backend (e.g., S3 + DynamoDB). Safe defaults and version constraints.
* **`vars.tf`** — Input variables for the root stack (CIDR blocks, domain names, tags, toggles, etc.).
* **`main.tf`** — Orchestrates root resources and exports outputs that service stacks consume (VPC IDs, subnets, SGs, DNS zone IDs, etc.).

---

## Environments & service stacks

Each environment folder (e.g. `clear_intent_dev/`) composes one or more **service stacks** (Admin, Backend, Frontend, Storybook). Typical patterns include:

* **Backend** (`backend/`):

  * ECS/Fargate services/tasks, service‐scoped IAM
  * RDS (PostgreSQL/MySQL) with parameter groups and security
  * Redis (Elasticache) for caching/queues
  * S3 buckets for reports/artifacts
  * KMS for encryption at rest
  * CI/CD via CodeBuild + CodePipeline, IAM roles for deploy
  * Optional Lambda functions (e.g., DB maintenance)

* **Frontend/Admin/Storybook** (`frontend/`, `admin/`, `storybook/`):

  * S3 website bucket + CloudFront distribution (origin access, OAC/OAI)
  * Cache and security headers (via CloudFront behaviors)
  * CodeBuild + CodePipeline for build & deploy from Git branches
  * DNS records → CloudFront distro or ALB as needed

All services share **root networking** and can register to the **shared ALB** or expose via **CloudFront**.

---

## Prerequisites

* Terraform **v1.x** (repo tested against a specific version via lockfile)
* AWS account with permissions to create networking, ECS, RDS, IAM, CloudFront, SES, Route 53, and Code\* services
* (Optional) Atlantis for GitOps automation
* (Optional) S3 + DynamoDB for remote state (recommended)

---

## Usage

1. **Clone & configure providers**

   * Update `provider.tf` backend block for your state bucket/table (or use local state while evaluating).
2. **Prepare variables**

   * Create `env/dev.tfvars`, `env/stg.tfvars`, `env/prod.tfvars` (or similar) with your CIDRs, domains, tags, and feature toggles.
3. **Init & plan**

   ```bash
   terraform init
   terraform workspace new dev || true
   terraform workspace select dev
   terraform plan -var-file=env/dev.tfvars
   ```
4. **Apply**

   ```bash
   terraform apply -var-file=env/dev.tfvars
   ```
5. **Deploy services**

   * Navigate into `clear_intent_dev/<service>/` and repeat `init/plan/apply` with that service’s `*.tfvars`.

> **Tip:** If using **Atlantis**, push a branch and open a PR. Atlantis will run `plan` and `apply` according to `.atlantis.yml` workflows after approvals.

---

## Variables & examples

This template uses descriptive variable names (e.g., `project_name`, `environment`, `vpc_cidr`, `public_subnet_cidrs`, `private_subnet_cidrs`, `domain_name`, `hosted_zone_id`, `enable_bastion`, `enable_ses`, `tags`, etc.).

Example `env/dev.tfvars` (redact/replace for public use):

```hcl
project_name    = "clear-intent"
environment     = "dev"
vpc_cidr        = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.0.0/20", "10.10.16.0/20"]
private_subnet_cidrs = ["10.10.32.0/20", "10.10.48.0/20"]
domain_name     = "example.dev"
hosted_zone_id  = "ZXXXXXXXXXXXXX"
enable_bastion  = true
enable_ses      = true
common_tags = {
  Owner       = "Platform"
  CostCenter  = "Demo"
  Environment = "dev"
}
```

Service stacks include their own variables (e.g., `image_tag`, `desired_count`, `db_instance_class`, `redis_node_type`, `cloudfront_price_class`, etc.).

---

## CI/CD (per service)

Each service folder defines:

* **CodeBuild** project to build artifacts or container images
* **CodePipeline** to orchestrate source → build → deploy
* **IAM** roles/policies granting least privilege for deployments
* **Deployment targets** (ECS service, S3 + CloudFront invalidations, etc.)

You can point pipelines at different branches per environment.

---

## Security considerations

* Keep state in a dedicated S3 bucket with **bucket policies** and **DynamoDB state locking**.
* Use **KMS‑encrypted** S3 buckets and EBS/RDS where applicable.
* Prefer **SSM Session Manager** over public SSH to bastions.
* Scope **security groups** tightly (no `0.0.0.0/0` on private services).
* Store secrets outside of Terraform state (e.g., **SSM Parameter Store**/**Secrets Manager**). Use data sources to read at apply time.

---

## Cost notes

* NAT Gateways can be significant. Consider **NAT instances** in dev/test or S3/CloudFront VPC endpoints to reduce egress.
* Turn down non‑prod ECS desired counts and RDS sizes.

---

## Cleanup

To destroy an environment, remove dependent service stacks first, then destroy the root stack:

```bash
terraform destroy -var-file=env/dev.tfvars
```

---

## Portfolio disclosure

This code structure reflects a real production engagement. **All identifiers, domains, and secrets in this public template are placeholders.** Replace them with your own values for a working deployment.


