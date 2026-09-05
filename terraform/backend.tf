terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_TF_STATE_BUCKET"
    key            = "lambda/dev/terraform.tfstate"
    region         = "REPLACE_WITH_YOUR_AWS_REGION"
    dynamodb_table = "REPLACE_WITH_YOUR_TF_LOCK_TABLE"
    encrypt        = true
  }
}
