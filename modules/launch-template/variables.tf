variable "lt-name" {
    description = "The name of the launch template."
    type        = string
}

variable "security-group-id" {
    description = "The security group ID to associate with the launch template."
    type        = string
}

variable "instance_type"{
    description = "The instance type to use for the launch template."
    type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile attached to EC2 instances"
  type        = string
}

variable "user_data" {
    description = "The user data to use for the launch template."
    type        = string
}