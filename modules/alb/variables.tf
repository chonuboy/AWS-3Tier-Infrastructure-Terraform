variable "alb_name" {
    description = "The name of the ALB."
    type        = string
}

variable "vpc_id" {
  description = "The Id of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "The Ids of the public subnets."
  type        = map(string)
}

variable "alb_security_group_id" {
  description = "The Id of the ALB Security Group."
  type        = string
}