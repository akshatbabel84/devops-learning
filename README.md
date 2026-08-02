# devops-learning
This repo is for DevOps learning purpose
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = "akshat-devops-learning-bucket-2026"
}

>> applied terraform init 

>> What terraform init actually did
- Found and downloaded the AWS provider plugin — specifically version 5.100.0, which satisfies your ~> 5.0 constraint (meaning "any 5.x, but not 6.0")
- Created .terraform/ — a hidden folder in your directory containing the actual downloaded provider binary/code. You never touch this manually.
- Created .terraform.lock.hcl — this is important. It records the exact version (5.100.0) that was installed, down to a cryptographic hash. This means if you or a teammate runs init again next month and HashiCorp has released 5.101.0, Terraform will still install 5.100.0 — guaranteeing everyone gets identical behavior. This is why the message says to commit this lock file to git — it's part of making your infrastructure reproducible, a core IaC principle.

>> terraform plan

Reading the plan output

The + symbol means "this will be created." If you ever see - it means "destroy," and ~ means "modify in place." This is the visual language of every Terraform plan — get used to spotting these three symbols, they tell you the story instantly.

(known after apply) — this is important to understand. Things like object_lock_configuration, versioning, website, etc. show this because AWS itself decides/generates these values once the bucket is actually created (some are defaults AWS assigns, some depend on server-side behavior). Terraform can't know them in advance — it only finds out after it actually talks to AWS. This is normal, not an error.

The summary line — this is the most important line in any plan output:

Plan: 1 to add, 0 to change, 0 to destroy.

This is Terraform's contract with you: exactly 1 new resource, nothing modified, nothing destroyed. Before running apply on any real project (especially client work later), this summary line is the first thing you check — if it ever says something unexpected like "3 to destroy" when you only meant to add something, that's your signal to stop and investigate before you accidentally delete someone's infrastructure.

The note about -out — Terraform is telling you that between plan and apply, someone else could change something in AWS, making this exact plan stale. For solo learning, ignore this. In real team/client work, best practice is:

bash
terraform plan -out=tfplan
terraform apply tfplan

This saves the exact plan to a file and forces apply to use precisely what was reviewed — no surprises. We'll adopt this habit starting next week; for today, keep it simple.

