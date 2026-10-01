output "subnet_ids" {
    description = "The IDs of the subnets created by the subnet module."
    value = {
        for name,subnet in aws_subnet.this : name => subnet.id
    }
}