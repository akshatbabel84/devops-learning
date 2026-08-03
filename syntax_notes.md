# Terraform Syntax Notes

Personal reference — patterns I keep forgetting. Add to this as I learn more.

## The core pattern (everything is built from this)

```hcl
block_type "label_1" "label_2" {
  argument_name = value
}
```

- `block_type` — fixed keyword Terraform understands (resource, variable, provider, etc.)
- Labels — some blocks need 0, 1, or 2 labels depending on the block type
- Arguments — `key = value` pairs inside `{ }`

## Quotes vs no quotes — the #1 thing I keep messing up

- **Quotes `"..."`** = literal value, exactly as typed
- **No quotes** = a reference/expression Terraform evaluates

```hcl
bucket = "my-actual-name"        # ✅ literal string
bucket = var.dev_bucket1         # ✅ reference to a variable, no quotes
bucket = "var.dev_bucket1"       # ❌ WRONG — this is now the literal text "var.dev_bucket1"
```

Booleans and numbers never get quotes:
```hcl
default = true      # ✅
default = "true"    # ❌ this is a string, not a boolean, if type = bool
```

Quick gut-check when stuck: **is this a block, an argument, or a reference?**
- Naming something new → block with labels
- Setting a property → argument (`key = value`)
- Pointing to another value → reference (no quotes)
- A fixed literal → quoted string

## `terraform` block — 0 labels

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
Tells Terraform which provider plugin to download (via `terraform init`). Runs once per project setup.

## `provider` block — 1 label

```hcl
provider "aws" {
  region = "ap-south-1"
}
```
Configures how Terraform connects to AWS. Credentials come from `aws configure` (CLI), never written in this file — safe to commit to git.

## `variable` block — 1 label

```hcl
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to create"
  default     = "my-default-value"
}
```
- `type` — string, bool, number, etc.
- `description` — optional but good practice, self-documents the code
- `default` — the FALLBACK value, only used if nothing else supplies one

Reference it elsewhere with `var.bucket_name` (no quotes).

### IMPORTANT: variable block vs .tfvars — they work TOGETHER, not as replacements
- `variable` block = the *declaration* (always stays in the code)
- `.tfvars` file = the *value override* for a specific run/environment
- Never delete the `variable` block just because you're using `.tfvars`

## Value precedence (highest wins)
1. `-var` command-line flag
2. `*.tfvars` file
3. Environment variable (`TF_VAR_...`)
4. `default` in the variable block (last resort only)

`terraform.tfvars` is auto-loaded by Terraform with no flags needed. Other named files (e.g. `dev.tfvars`) need `-var-file="dev.tfvars"`.

```hcl
# terraform.tfvars — just key = value, no "variable" keyword, no quotes around the name
dev_bucket1       = "my-bucket-name"
enable_versioning = false
```

## `resource` block — 2 labels

```hcl
resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.dev_bucket1

  tags = {
    Environment = var.environment
  }
}
```
- Label 1 = resource TYPE (fixed name from the provider, e.g. `aws_s3_bucket`)
- Label 2 = MY nickname for it in code only (not the real AWS name)
- `tags` is its own separate argument — a map of `{ key = value }` labels for organizing/billing. NOT nested inside `bucket`.

## Referencing another resource's attribute

Pattern: `resource_type.local_name.attribute` (no quotes — it's a reference)

```hcl
resource "aws_s3_bucket_versioning" "my_first_bucket_versioning" {
  bucket = aws_s3_bucket.my_first_bucket.id   # <- referencing the bucket's id
  versioning_configuration {
    status = "Enabled"
  }
}
```
Terraform automatically figures out create-order from these references — bucket gets created before versioning, no need to specify manually.

## Conditional expression (ternary)

Pattern: `condition ? value_if_true : value_if_false`

```hcl
status = var.enable_versioning ? "Enabled" : "Suspended"
```

## Plan output symbols

- `+` = create
- `-` = destroy
- `~` = update in-place
- `(known after apply)` = AWS will generate this value once the resource actually exists; normal, not an error

## AWS-specific gotcha learned the hard way

S3 versioning can NEVER go back to fully "Disabled" once it's been "Enabled" — only `"Enabled"` or `"Suspended"`. This is an AWS API rule, not a Terraform limitation. Suspended = stops new versions, keeps existing ones, doesn't touch real data.

## Safety commands / habits

```bash
terraform init      # download provider plugins (once per project, or when providers change)
terraform plan       # DRY RUN — shows what would happen, changes nothing
terraform apply      # actually creates/changes real infrastructure, asks for confirmation
terraform destroy    # removes everything Terraform manages — ONLY for disposable/test infra, never real data
```

- `force_destroy = true` on a bucket resource overrides AWS's built-in protection against deleting a bucket with objects in it — dangerous, never set this on anything with real data.
- Always check the summary line before confirming: `Plan: X to add, Y to change, Z to destroy` — this is the contract, read it before typing `yes`.
- `terraform.tfstate` = Terraform's memory of real infrastructure. Never edit by hand. Never delete casually.

## .gitignore for Terraform projects

```
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
```
Commit `.terraform.lock.hcl` — do NOT ignore it (locks exact provider version for reproducibility).

## Security habit

Never paste real AWS access keys anywhere they could be logged/seen (chat, screenshots, commits). If exposed, rotate immediately: deactivate + delete old key, create new one.
