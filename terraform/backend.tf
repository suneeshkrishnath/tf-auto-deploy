terraform {
  backend "s3" {
    bucket         = "weather-and-wo-app-v0"
    key            = "lambda/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "table-weather-lambda-auto-deploy"
    encrypt        = true
  }
}
