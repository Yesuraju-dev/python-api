provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "flask_ecr" {
  name = "flask-api-repository"
}

resource "aws_ecs_cluster" "flask_cluster" {
  name = "flask-cluster"
}

resource "aws_ecs_task_definition" "flask_task" {
  family                   = "flask-api-task"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name      = "flask-api"
    image     = "${aws_ecr_repository.flask_ecr.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "flask_service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.flask_cluster.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = 1

  network_configuration {
    subnets          = ["subnet-xxxxxxxx"]
    security_groups = ["sg-xxxxxxxx"]
    assign_public_ip = true
  }
}
