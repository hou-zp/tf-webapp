terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/alicloud"
      version = "~> 1.138"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }
  }
}
