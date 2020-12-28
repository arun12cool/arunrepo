provider "aws"{
  region = "us-east-1"
}
resource "aws_opsworks_instance" "DR-hypertrail-staging-1" {
  stack_id = var.Stack_id_hypertrail

  hostname = "dr-hypertrail-staging-1"
  subnet_id = var.private_subnetid-d
  agent_version = "4037-20190604080613"
  virtualization_type = "hvm"
  availability_zone = var.availability_zone-d
  ebs_optimized = true
  root_device_type = "ebs"
  security_group_ids = ["$(var.hypertrail-staging)","$(var.APP_SEC_GRP)"]
  layer_ids = [var.hypertrail-staging_dr]
  instance_type = "m5.large"
  ami_id        = var.ami_id
  os            = "Custom"
  state         = "running"
}

resource "aws_opsworks_instance" "DR-hypertrail-staging-2" {
  stack_id = var.Stack_id_hypertrail

  hostname = "dr-hypertrail-staging-2"
  subnet_id = var.private_subnetid-f
  agent_version = "4037-20190604080613"
  virtualization_type = "hvm"
  availability_zone = var.availability_zone-f
  ebs_optimized = true
  root_device_type = "ebs"
  security_group_ids = ["$(var.hypertrail-staging)","$(var.APP_SEC_GRP)"]
  layer_ids = [var.hypertrail-staging_dr]
  instance_type = "m5.large"
  ami_id        = var.ami_id
  os            = "Custom"
  state         = "running"
}

resource "aws_lb" "hypertrail-staging-dr-alb" {
  name               = "hypertrail-staging-dr-alb"
  internal           = false
  load_balancer_type = "application"
  enable_http2       = false
  security_groups    = [
        "sg-48465b34",
  ]
  subnets           = [
        "subnet-0822f464b7cd50dd2",
        "subnet-0bf2f989863c7cea2"
  ]
  tags = {
    Name = "Hypertrail-staging-dr-alb"
  }
}
resource "aws_lb_target_group" "hypertrail-service-tg-dr" {
  name     = "hypertrail-service-tg-dr"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/health"
    healthy_threshold = "2"
    unhealthy_threshold = "2"
    timeout = "5"
    interval = "30"
  }
}

resource "null_resource" "before" {
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  triggers = {
    "before" = "${null_resource.before.id}"
  }
}

resource "null_resource" "after" {
  depends_on = [null_resource.delay]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.hypertrail-staging-dr-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.hypertrail-service-tg-dr.arn
  }
}

resource "aws_lb_listener" "front_end1" {
  load_balancer_arn = aws_lb.hypertrail-staging-dr-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:206535303787:certificate/142c5730-a556-446a-9e88-ed6650cc7258"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.hypertrail-service-tg-dr.arn
  }
}


resource "aws_lb" "hypertrail-staging-dr-ilb" {
  name               = "hypertrail-staging-dr-ilb"
  internal           = true
  load_balancer_type = "application"
  enable_http2       = false
  security_groups    = [
        "sg-008d4ec23c087c1ea",
  ]
  subnets           = [
        "subnet-073ce6ee043d411cb",
        "subnet-02bc8453b188f1483"
  ]
  tags = {
    Name = "Hypertrail-staging-dr-ilb"
  }
}
resource "aws_lb_target_group" "hypertrail-service-tg-dr-ilb" {
  name     = "hypertrail-service-tg-dr-ilb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/health"
    healthy_threshold = "2"
    unhealthy_threshold = "2"
    timeout = "5"
    interval = "30"
  }
}


resource "aws_lb_listener" "front_end3" {
  load_balancer_arn = aws_lb.hypertrail-staging-dr-ilb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.hypertrail-service-tg-dr-ilb.arn
  }
}

resource "aws_lb_listener" "front_end4" {
  load_balancer_arn = aws_lb.hypertrail-staging-dr-ilb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:206535303787:certificate/142c5730-a556-446a-9e88-ed6650cc7258"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.hypertrail-service-tg-dr-ilb.arn
  }
}


resource "aws_lb_target_group_attachment" "DR-3" {
  depends_on       = [aws_opsworks_instance.DR-hypertrail-staging-1]
  target_group_arn = aws_lb_target_group.hypertrail-service-tg-dr-ilb.arn
  target_id        = aws_opsworks_instance.DR-hypertrail-staging-1.ec2_instance_id
  port             = 32765
}

resource "aws_lb_target_group_attachment" "DR-4" {
  depends_on       = [aws_opsworks_instance.DR-hypertrail-staging-2]
  target_group_arn = aws_lb_target_group.hypertrail-service-tg-dr-ilb.arn
  target_id        = aws_opsworks_instance.DR-hypertrail-staging-2.ec2_instance_id
  port             = 32766
}

output "aws_lb_arn" {
  value = aws_lb.hypertrail-staging-dr-alb.arn
}
