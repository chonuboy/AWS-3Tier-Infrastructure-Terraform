variable "vpc_id" {
    description = "The ID of the VPC where the route tables will be created."
    type        = string            
} 

variable "public_subnet_ids" {
    description = "The ID of the public subnet to associate with the public route table."
    type        = map(string)
}

variable "private_subnet_app_ids" {
    description = "The ID of the private subnet to associate with the private route table."
    type        = map(string)
}

variable "private_subnet_db_ids" {
    description = "The ID of the private subnet to associate with the private route table."
    type        = map(string)
}

variable "nat_subnet_id" {
    description = "The ID of the NAT subnet to associate with the private route table."
    type        = string
}
