resource "aws_route53_zone" "main" {
  name = "team-train.cloud"

  tags = {
    Name        = "team-train-zone"
    Environment = "global"
  }
}