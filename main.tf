###########
# Provider
###########
terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "local" {}
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

##################
# Local Variables
##################
locals {
  name = "${var.project}_${var.env}"
}

#############################
# Activate Security Services
#############################
#########
# Config
#########
module "config" {
  source = "./modules/config"
}

#########
# SecurityHub
#########
module "securityhub" {
  source = "./modules/securityhub"
}

#########
# GuardDuty
#########
module "guardduty" {
  source = "./modules/guardduty"
}

#########
# Inspector
#########
module "Inspector" {
  source = "./modules/Inspector"
}

##########################
# Basic Configrations
##########################
#########
# IAM
#########
module "iam" {
  source = "./modules/iam"
}

#########
# EC2
#########
module "ec2" {
  source = "./modules/ec2"
}

#########
# S3
#########
module "s3" {
  source = "./modules/s3"
}
