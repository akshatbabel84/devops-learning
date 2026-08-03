# devops-learning

This repo is for DevOps learning purpose.

## Day 1

```hcl
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
```

Applied `terraform init`.

### What `terraform init` actually did

- Found and downloaded the AWS provider plugin — specifically version 5.100.0, which satisfies the `~> 5.0` constraint (meaning "any 5.x, but not 6.0")
- Created `.terraform/` — a hidden folder containing the actual downloaded provider binary/code. Never touched manually.
- Created `.terraform.lock.hcl` — records the exact version (5.100.0) installed, down to a cryptographic hash. This means running `init` again later will still install 5.100.0, guaranteeing everyone gets identical behavior. This is why the lock file gets committed to git — it's part of making infrastructure reproducible, a core IaC principle.

### `terraform plan`

**Reading the plan output:**

The `+` symbol means "this will be created." `-` means "destroy," and `~` means "modify in place." This is the visual language of every Terraform plan.

`(known after apply)` — things like `object_lock_configuration`, `versioning`, `website` show this because AWS itself decides/generates these values once the resource is actually created. Terraform can't know them in advance. Normal, not an error.

**The summary line** — the most important line in any plan output:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

This is Terraform's contract: exactly what will change. Before running `apply` on any real project, this line is the first thing to check — an unexpected "3 to destroy" is the signal to stop and investigate before accidentally deleting real infrastructure.

**The `-out` note** — Terraform warning that between `plan` and `apply`, someone else could change something in AWS, making the plan stale. For solo learning, ignore. In real team/client work, best practice is:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

This saves the exact reviewed plan to a file and forces `apply` to use precisely that — no surprises.

---

## Day 2

Built on top of the Day 1 bucket by adding variables, tags, a versioning resource, and a `.tfvars` file.

```hcl
variable "dev_bucket1" {
  type        = string
  description = "Name of the s3 bucket to create"
  default     = "akshat-devops-learning-bucket-2026"
}

variable "enable_versioning" {
  type        = bool
  description = "Controls whether bucket versioning is enabled"
  default     = true
}

variable "environment" {
  type        = string
  description = "Environment tag, e.g. dev or prod"
  default     = "dev"
}

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.dev_bucket1

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "my_first_bucket_versioning" {
  bucket = aws_s3_bucket.my_first_bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
```

### What was learned

- **Variables** make code reusable — `default` is the fallback used only when nothing else supplies a value. Actual overrides come from a `terraform.tfvars` file, `-var` flags, or environment variables, in that order of priority.
- **`variable` blocks and `.tfvars` files work together, not as replacements.** The `variable` block is the declaration (always stays in code); `.tfvars` only supplies an override value for a specific run/environment.
- **Resource references** — `aws_s3_bucket.my_first_bucket.id` lets one resource reference another's attribute. Terraform auto-detects the dependency and creates resources in the correct order without being told explicitly.
- **Conditional expressions (ternary)** — `condition ? value_if_true : value_if_false`, used to drive `status` from the `enable_versioning` variable.
- **Real AWS constraint discovered:** once S3 versioning is `Enabled`, it can never go back to `Disabled` — only `Enabled` or `Suspended`. Attempting `"Disabled"` throws a real AWS API error, not a Terraform bug. `Suspended` stops new versions being created but keeps all existing versions and data intact — the safe way to "turn off" versioning on a bucket with real data.
- **`terraform destroy` is only safe for disposable/test infrastructure**, never for anything with real data — in-place `apply` changes (like Enabled → Suspended) are the safe path for real resources. `force_destroy = true` is a dangerous flag that overrides AWS's built-in protection against deleting a non-empty bucket, and should never be set on production data.

### Next

Repetition drills — rebuilding this same S3 + variables + versioning setup from a blank file, multiple times, before introducing new concepts. See `SYNTAX_NOTES.md` for the syntax cheat sheet.