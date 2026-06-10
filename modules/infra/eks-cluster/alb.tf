# ALB 생성
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  # ALB 액세스 로그 → ops-logs S3 버킷
  access_logs {
    bucket  = var.ops_logs_bucket_id
    prefix  = "alb"
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  }
}

# HTTP → HTTPS 리다이렉트
resource "aws_lb_listener" "front_http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "front_https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Target Group - TargetGroupBinding 방식으로 ALB Controller가 Pod IP 자동 등록
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-${var.environment}-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-tg"
    Environment = var.environment
  }
}

# TargetGroupBinding 방식 사용으로 aws_lb_listener_rule 불필요 - 삭제
# ALB Controller가 TargetGroupBinding CRD를 통해 자동으로 Pod IP 등록