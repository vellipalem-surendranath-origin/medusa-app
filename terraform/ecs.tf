resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

resource "aws_ecs_task_definition" "medusa_task" {
  family                = "medusa-task"
  network_mode          = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"

  container_definitions = jsonencode([
    {
      name  = "medusa",
      image = "jmflaherty/medusajs-backend:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocal      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.medusa_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "medusa"
        }
      },
      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.medusa_db.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.medusa_db.port)
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.medusa_db.name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
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
  launch_type     = "FARGATE"
  force_new_deployment  = true

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
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Temporarily allow all IPs for testing
    self        = true
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
  source_security_group_id = tolist(aws_lb.medusa_alb.security_groups)[0]
  # source_security_group_id = aws_lb.medusa_alb.security_groups[count.index]
}
