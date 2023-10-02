variable "env" {
  type        = string
  description = "Current state of project: stage, prod"
}

variable "project" {
  type        = string
  description = "The Project prefix."
}

variable "profile" {
  type        = string
  description = "Profile of IAM User"
}

variable "region" {
  type        = string
  description = "AWS Region"
}
