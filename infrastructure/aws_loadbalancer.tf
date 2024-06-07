# Create load balancer
resource "aws_lb" "team5-aws-lb" {
  name            = "team5-lb"
  internal        = false
  load_balancer_type = "application"
  subnets         = module.team5-vpc.public_subnets
  security_groups = [aws_security_group.team5-lb-security-group.id]

  enable_deletion_protection = false

  enable_http2                     = true
  idle_timeout                     = 60
  enable_cross_zone_load_balancing = false

  depends_on = [ aws_security_group.team5-lb-security-group ]
}

# Create load balancer target group
resource "aws_lb_target_group" "team5-aws-lb-target-group" {
  name     = "team5-lb-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = module.team5-vpc.vpc_id

  # Define health check
  health_check {
    path                = "/"
    port                = "traffic-port"
    matcher             = "200,302"
  }

  # Statefull loadbalancing
  stickiness {
    type = "lb_cookie"
  }
}

# Create load balancer listener
resource "aws_lb_listener" "team5-aws-lb-listener" {
  load_balancer_arn = aws_lb.team5-aws-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.team5-aws-lb-target-group.arn
    type             = "forward"
  }
}

# Create load balancer security group
resource "aws_security_group" "team5-lb-security-group" {
  name   = "team5-security-group-lb"
  vpc_id = module.team5-vpc.vpc_id

  # Only allow HTTP inbound traffic
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}