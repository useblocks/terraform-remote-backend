provider "aws" {
  region = "eu-central-1"
}

################ S3 Bucket ################

resource "aws_s3_bucket" "terraform_state" {
  bucket = "ub-tf-remote-state"
  force_destroy = true
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

################ AWS DynamoDB ################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

############## Terraform backend configuration ################

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "ub-tf-remote-state"
    key            = "remote-backend/terraform.tfstate"
    region         = "eu-central-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}