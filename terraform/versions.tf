# versions.tf
# Pins the tools and providers so every machine builds the SAME thing.
# Without this, two people could get different results from the same code.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # any 5.x release
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4" # used to zip the Lambda code
    }
  }
}
