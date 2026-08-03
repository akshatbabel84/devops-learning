## Day 1 — Aug 2, 2026
**What I built:** First Terraform-managed AWS resource — an S3 bucket, using GitHub Codespaces as my dev environment (blocked from installing tools locally due to corporate Zscaler proxy).

**What I learned:**
- HCL block syntax: block_type "label1" "label2" { arguments }
- terraform init/plan/apply/destroy workflow
- terraform.tfstate is Terraform's memory of real infrastructure
- Never expose AWS access keys in chat/logs — rotate immediately if exposed

**What broke:** Typo in provider source (hashicop vs hashicorp) — good reminder to read Terraform error messages carefully, they're usually precise.

**Next:** Add variables instead of hardcoded values, explore outputs.

## Day 2 — Aug 3, 2026

**What I built:**
- Added 3 variable blocks: `dev_bucket1`, `enable_versioning` (bool), `environment` (string)
- Added a `tags` argument on the S3 bucket resource, referencing `var.environment`
- Added a new resource block, `aws_s3_bucket_versioning`, which references the bucket
  via `aws_s3_bucket.my_first_bucket.id` — Terraform auto-detects this dependency and
  creates the bucket first, versioning second, without me specifying order.
- Used a conditional expression (ternary) to drive the versioning status from the
  `enable_versioning` variable: `var.enable_versioning ? "Enabled" : "Suspended"`
- Created a `terraform.tfvars` file to override variable defaults without touching
  the code (e.g. `enable_versioning = false`, `environment = "prod"`)

**What broke / what I learned:**
- First tried `status = ... ? "Enabled" : "Disabled"` — AWS rejected this with
  "versioning_configuration.status cannot be updated from 'Enabled' to 'Disabled'".
  Learned this is a real AWS API rule, not a Terraform bug: once versioning is
  Enabled on a bucket, it can only go to Suspended, never back to Disabled.
  Suspended stops new versions but keeps all existing ones and existing data untouched.
- Fixed by changing the conditional to `"Enabled" : "Suspended"`.
- Learned `terraform destroy` is only safe for disposable/test infrastructure —
  never for real data. For real buckets, in-place changes via `apply` (like
  Enabled → Suspended) are the safe path; `force_destroy = true` is the dangerous
  flag that would let a bucket with real data be deleted, and should basically
  never be set on production data.

**Confusion cleared up:**
- The `variable` block and a `.tfvars` file are NOT interchangeable — they work
  together. The `variable` block is the *declaration* and must always stay in the
  code. The `.tfvars` file only *supplies a value* that overrides the block's
  `default`. Deleting the `variable` block breaks the reference (`var.x`) entirely.

**Reflection:**
- I understand the concepts and can read/debug Terraform code correctly, but I'm
  not yet fluent writing it from a blank file without referencing prior examples.
  Decided to spend tomorrow's session purely on repetition — rebuilding this same
  S3 + versioning + variables setup from scratch, multiple times, no new concepts.
- Started a SYNTAX_NOTES.md cheat sheet to reference instead of re-asking each time.

**Next:** Repetition drills on today's syntax before introducing any new concepts.