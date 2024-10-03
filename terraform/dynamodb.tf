provider "aws" {
  region = "us-east-1"  # Set your AWS region
}

resource "aws_dynamodb_table" "gitops-proj-dynamodb-statelock" {
  name         = "gitops-proj-dynamodb-statelock"  # Table name for state locking
  billing_mode = "PAY_PER_REQUEST"       # Pay per request to simplify capacity management

  hash_key     = "LockID"  # The primary key for locking

  attribute {
    name = "LockID"
    type = "S"  # String type for the primary key
  }

  tags = {
    Name = "Terraform State Lock Table"
    Environment = "Dev"  # Customize as needed
  }
}
