terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }
  backend "s3" {
    bucket       = "prashant-tfstates-bucket"
    region       = "ap-south-1"
    key          = "karpentereks/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws-region
}
