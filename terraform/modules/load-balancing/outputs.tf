output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = aws_lb.wordpress.dns_name
}

output "alb_arn" {
  description = "ARN do ALB"
  value       = aws_lb.wordpress.arn
}

output "alb_zone_id" {
  description = "Zone ID do ALB"
  value       = aws_lb.wordpress.zone_id
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.wordpress.arn
}

output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.name
}

output "asg_arn" {
  description = "ARN do ASG"
  value       = aws_autoscaling_group.wordpress.arn
}
