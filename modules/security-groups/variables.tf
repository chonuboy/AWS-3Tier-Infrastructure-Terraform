variable "alb_sg_name" {
    type        = string
    description = "The name of the security group."
}

variable "vpc_id" {
    type        = string
    description = "The ID of the VPC where the security group will be created."
}

variable "app_sg_name" {
    type        = string
    description = "The name of the security group for the application."
}

variable "db_sg_name" {
    type        = string
    description = "The name of the security group for the database."
}