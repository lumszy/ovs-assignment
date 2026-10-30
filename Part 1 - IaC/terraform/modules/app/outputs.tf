output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer."
  value       = aws_lb.app.dns_name
}

output "load_balancer_zone_id" {
  description = "Hosted zone ID of the application load balancer."
  value       = aws_lb.app.zone_id
}

output "target_group_arn" {
  description = "Target group ARN used by the ALB."
  value       = aws_lb_target_group.app.arn
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name used by the app tier."
  value       = aws_iam_instance_profile.app.name
}
