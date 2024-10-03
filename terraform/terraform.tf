terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }

  backend "s3" {
    bucket = "marcuskoh95-gitops-proj-s3-terraformstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "gitops-proj-dynamodb-statelock"
  }

  required_version = "~> 1.9.5"
}
##
##
##
