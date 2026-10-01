variable "subnets" {
    description = "A list of subnets to create in the VPC."

    type = map(object({
        cidr_block = string
        availability_zone = string
        map_public_ip_on_launch = bool
        tier = string
    }))
}

variable "vpc_id" {
    description = "The ID of the VPC where the subnets will be created."
    type        = string
}