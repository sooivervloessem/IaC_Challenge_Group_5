terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  backend "http" {
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_token
}

# Configure Docker provider
provider "docker" {
  host = var.docker_sock

  registry_auth {
    address  = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/iac-team-5/aws-iac-challenge-team-5:latest"
    username = var.gitlab_username
    password = var.gitlab_access_token

  }
}