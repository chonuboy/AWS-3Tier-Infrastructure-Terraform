output "alb_security_group_id" {
  description = "ID of the ALB Security Group"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the App Security Group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the DB Security Group"
  value       = aws_security_group.db.id
}