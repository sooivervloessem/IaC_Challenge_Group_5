output "load_balancer_dns" {
  value = aws_lb.team5-aws-lb.dns_name
}

output "database_host" {
  value = aws_db_instance.team5-db.address
}

# output "content_dockerfile" {
#   value = file("../application/.env.variables")
# }