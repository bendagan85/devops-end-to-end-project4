terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-project4" 
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # בונוס נוסף: DynamoDB לנעילת הסטייט (מונע התנגשויות)
    # dynamodb_table = "terraform-lock" 
  }
}

provider "aws" {
  region = "us-east-1"
}