output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC created by the VPC module."
}

output "subnet_ids" {
  description = "Value of the Subnet Ids"
  value       = module.subnet.subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.route_tables.internet_gateway_id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.route_tables.public_route_table_id
}

output "private_app_route_table_id" {
  description = "ID of the private application route table"
  value       = module.route_tables.private_app_route_table_id
}

output "private_db_route_table_id" {
  description = "ID of the private database route table"
  value       = module.route_tables.private_db_route_table_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.route_tables.nat_gateway_id
}

output "nat_eip" {
  description = "Elastic IP associated with the NAT Gateway"
  value       = module.route_tables.nat_eip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "ARN of the application target group"
  value       = module.alb.target_group_arn
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "iam_role_name" {
  description = "EC2 IAM role name"
  value       = module.iam.role_name
}

output "iam_instance_profile_name" {
  description = "EC2 IAM instance profile name"
  value       = module.iam.instance_profile_name
}