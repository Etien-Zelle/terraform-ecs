provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4NWHE6ECS42ZTWW3"
  secret_key = "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"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  #id = "vpc-0f5e1af3931da4aa9"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "alb" {
  name = "alb_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
}

resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "aws_alb" "main" {
  name = "main"
  internal = false
  security_groups = [aws_security_group.alb.id]
  subnets = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"
  network_mode = "bridge"

  container_definitions = <<EOF
[
{
  "name": "nginx",
  "image": "nginx:latest",
  "memory": 256,
  "portMappings": [
    {
      "containerPort": 80,
      "hostPort": 80
    }
  ],
  "essential": true
}
]
EOF
}

resource "aws_ecs_service" "nginx" {
  name = "nginx"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count = 1
  load_balancer {
    target_group_arn = aws_alb_target_group.nginx.arn
    container_name = "nginx"
    container_port = 80
  }
}

resource "aws_alb_target_group" "nginx" {
  name                = "nginx"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.main.id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
} 
resource "aws_s3_bucket" "et_bucket" {
  bucket = "et-bucket"
}
 
