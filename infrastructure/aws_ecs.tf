# Create AWS ECS cluster and enable insights
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
# Fetch the current account ID
data "aws_caller_identity" "team5-current" {}

# Fetch gitlab credentials arn from secrets manager
data "aws_secretsmanager_secret" "team5-secret-arn" {
  arn = "${aws_secretsmanager_secret.team5-secretsmanager-gitlab-credentials.arn}"
}

# Create AWS ECS task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "team5-ecs-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 512
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.team5-current.account_id}:role/LabRole"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.team5-current.account_id}:role/LabRole"

  # Create a container definition for the task definition
  # This defines the container name, image, resources and port mappings
  container_definitions    = <<DEFINITION
[
  {
    "name": "team5-bookstack",
    "image": "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/iac-team-5/aws-iac-challenge-team-5:latest",
    "repositoryCredentials": {
      "credentialsParameter": "${data.aws_secretsmanager_secret.team5-secret-arn.arn}"
    },
    "memory": 2048,
    "cpu": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "awslogs-bookstack",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "awslogs-example"
         }
    },
    "environment": [
      {
        "name" : "APP_URL",
        "value" : "http://${aws_lb.team5-aws-lb.dns_name}"
      },
      {
        "name" : "DB_HOST",
        "value" : "${aws_db_instance.team5-db.address}"
      },
      {
        "name" : "DB_DATABASE",
        "value" : "${var.aws_db_database}"
      },
      {
        "name" : "DB_USERNAME",
        "value" : "${var.aws_db_username}"
      },
      {
        "name" : "DB_PASSWORD",
        "value" : "${var.aws_db_password}"
      }
    ],
    "command": [ 
      "sh", "-c", "php artisan migrate --force && apache2ctl -D FOREGROUND"
    ]
  }
]
DEFINITION

  depends_on = [ aws_ecs_cluster.ecs_cluster, data.aws_caller_identity.team5-current]
}

# AWS SERVICE
resource "aws_ecs_service" "ecs_service" {
  name            = "team5-service"
  cluster         = aws_ecs_cluster.ecs_cluster.name
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.team5-vpc.public_subnets
    security_groups  = [aws_security_group.team5-ecs-sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.team5-aws-lb-target-group.arn
    container_name   = "team5-bookstack"
    container_port   = 80
  }

  depends_on = [ aws_lb_target_group.team5-aws-lb-target-group, aws_ecs_cluster.ecs_cluster]
}

resource "aws_security_group" "team5-ecs-sg" {
  name        = "team5-ecs-sg"
  description = "Allow all inbound traffic"
  vpc_id      = module.team5-vpc.vpc_id

  # Only allow inbound traffic from the load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.team5-lb-security-group.id] 
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}