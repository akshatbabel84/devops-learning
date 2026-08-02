## Day 1 — [today's date]
**What I built:** First Terraform-managed AWS resource — an S3 bucket, using GitHub Codespaces as my dev environment (blocked from installing tools locally due to corporate Zscaler proxy).

**What I learned:**
- HCL block syntax: block_type "label1" "label2" { arguments }
- terraform init/plan/apply/destroy workflow
- terraform.tfstate is Terraform's memory of real infrastructure
- Never expose AWS access keys in chat/logs — rotate immediately if exposed

**What broke:** Typo in provider source (hashicop vs hashicorp) — good reminder to read Terraform error messages carefully, they're usually precise.

**Next:** Add variables instead of hardcoded values, explore outputs.
