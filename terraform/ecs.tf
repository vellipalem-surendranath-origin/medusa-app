resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

resource "aws_ecs_task_definition" "medusa_task" {
  family                = "medusa-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"

  container_definitions = jsonencode([
    {
      name  = "medusa",
      image = "medusajs/medusa:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets  # Use private subnets if behind ALB
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa_tg.arn
    container_name   = "medusa"
    container_port   = 9000
  }

  depends_on = [aws_lb_listener.http_listener]
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Temporarily allow all IPs for testing
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_alb" {
  type        = "ingress"
  from_port   = 9000
  to_port     = 9000
  protocol    = "tcp"
  security_group_id = aws_security_group.ecs_sg.id

  # Reference ALB security groups
  source_security_group_id = aws_lb.medusa_alb.security_groups[0]
  # source_security_group_id = aws_lb.medusa_alb.security_groups[count.index]
}
