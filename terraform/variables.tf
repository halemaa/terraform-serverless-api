# variables.tf
# Variables are the "settings" of the project. Change them here instead of
# hunting through every file. Each has a sensible default, so the project
# works with zero configuration.

variable "aws_region" {
  description = "AWS region to deploy into. eu-west-1 (Ireland) is a good low-latency choice from Kenya."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Short name used to tag and prefix every resource, so they are easy to find and delete."
  type        = string
  default     = "serverless-items-api"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod). Kept as a tag and name suffix."
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "How many days to keep Lambda logs. Short retention keeps the (already tiny) log bill near zero."
  type        = number
  default     = 14
}
