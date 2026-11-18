# dynamodb.tf
# The "filing cabinet" — a DynamoDB table that stores each item (note) by id.
#
# billing_mode = PAY_PER_REQUEST means on-demand: you pay only for the reads
# and writes you actually make. No idle hourly charge. Perfect for a portfolio
# project that mostly sits still.

resource "aws_dynamodb_table" "items" {
  name         = "${local.name_prefix}-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id" # the partition key — how we look items up

  attribute {
    name = "id"
    type = "S" # S = String
  }

  # Encrypt the data at rest. AWS-managed key, no extra cost.
  server_side_encryption {
    enabled = true
  }

  # Let AWS keep automatic backups for the last 35 days.
  point_in_time_recovery {
    enabled = true
  }
}
