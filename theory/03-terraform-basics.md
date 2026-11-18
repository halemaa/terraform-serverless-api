# 3. Terraform basics

Terraform is the tool that reads your `.tf` files and builds the real
infrastructure. Four ideas cover 90% of it.

## 1. Provider — which cloud
The `provider` block says which cloud and region to talk to. Ours
([`main.tf`](../terraform/main.tf)) points at AWS in `eu-west-1`. Terraform can
drive AWS, Google Cloud, Azure, and hundreds of others — the same language for
all of them. That portability is Terraform's big advantage over AWS's own
CloudFormation (which is AWS-only).

## 2. Resource — a thing you want to exist
A `resource` block describes one piece of infrastructure. For example:

```hcl
resource "aws_dynamodb_table" "items" {
  name         = "serverless-items-api-dev-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  ...
}
```

Read it as: *"there should be a DynamoDB table that looks like this."* You
describe the **end state you want**, not the steps to get there. This is called
being **declarative**.

## 3. plan and apply — preview, then build
Two commands you'll use constantly:

- `terraform plan` — a **preview**. It compares "what you want" (the files) to
  "what exists" and prints exactly what it *would* create, change, or destroy.
  It changes nothing. **Always read the plan.**
- `terraform apply` — actually makes the changes, after you type `yes`.

And when you're done: `terraform destroy` removes everything.

## 4. State — Terraform's notebook (the tricky one)
After it builds something, Terraform writes down what it made in a **state
file** (`terraform.tfstate`). This is its memory.

Why it matters: next time you run `plan`, Terraform compares three things —
your files (desired), the state (what it thinks it built), and the real cloud —
to work out the *minimum* change needed. Without state, it couldn't tell "create
a new table" apart from "this table already exists, leave it alone."

Two beginner rules about state:
1. **Don't edit it by hand.** Let Terraform manage it.
2. **It can contain secrets**, so it's gitignored here. In a team, you'd store
   it in a shared, encrypted "remote backend" (e.g. an S3 bucket) so everyone
   works from the same notebook — see limitation #5 in
   [`SECURITY.md`](../SECURITY.md).

## Putting it together
A normal Terraform session looks like:

```bash
terraform init      # download the AWS provider (once)
terraform fmt       # auto-format the files
terraform validate  # is the syntax/logic valid?
terraform plan      # preview the changes
terraform apply     # build it
```

Those first three steps need no cloud access at all — which is exactly why the
[CI pipeline](../.github/workflows/terraform.yml) can run them on every change
with no AWS credentials.

Next: [the architecture, end to end →](04-the-architecture.md)
