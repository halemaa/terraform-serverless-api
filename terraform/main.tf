# main.tf
# The provider block tells Terraform WHICH cloud and region to talk to.
# default_tags are stamped onto every resource automatically — this is how
# you keep a cloud account tidy and know what created each thing.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "halemaa"
    }
  }
}

# A "data source" READS something that already exists (it does not create).
# Here we read the current AWS account ID and region, used to build ARNs
# (Amazon Resource Names — the unique address of every cloud resource).
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # One place to assemble the resource name prefix: "serverless-items-api-dev"
  name_prefix = "${var.project_name}-${var.environment}"
}
