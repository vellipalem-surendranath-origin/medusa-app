resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

resource "aws_ecs_task_definition" "medusa_task" {
  family                = "medusa-task"
  network_mode          = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"

  container_definitions = jsonencode([
    {
      name  = "medusa"
      image = "anudeep1/medusa_app:latest"
      essential = true
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocal      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.medusa_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "medusa"
        }
      }
      environment = [
      # PostgreSQL connection settings
      { name = "POSTGRES_HOST", value = aws_db_instance.medusa_db.address },
      { name = "POSTGRES_USER", value = aws_db_instance.medusa_db.username },
      { name = "POSTGRES_PASSWORD", value = aws_db_instance.medusa_db.password },
      { name = "POSTGRES_DB", value = "medusa" },
      
      # Redis connection settings
      { name = "REDIS_URL", value = "redis://${aws_elasticache_cluster.medusa.cache_nodes[0].address}:6379" }
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
    subnets         = ["subnet-0c9b473d9397d8d61","subnet-0de0da3c4f069e929","subnet-01e20ef74422cd971"]
    security_groups = [aws_security_group.medusa_sg.id]
    assign_public_ip = true
  }
}
