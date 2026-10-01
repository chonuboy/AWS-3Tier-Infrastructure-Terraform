variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "launch_template_id" {
  description = "Launch template ID"
  type        = string
}

variable "launch_template_version" {
  description = "Launch template version"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private application subnet IDs"
  type        = map(string)
}

variable "target_group_arns" {
  description = "Target group ARNs for the application"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
}