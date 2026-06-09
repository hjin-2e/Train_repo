aws_region    = "ap-northeast-2"
project_name  = "team-train"
environment   = "dev"        
developer_ips = ["0.0.0.0/0"]

# 첫 배포를 위한 더미 값
cloudfront_domain_name = "dummy-cf.cloudfront.net"
cloudfront_zone_id     = "Z2FDTNDATAQYW2"
alb_dns_name           = "dummy-alb.ap-northeast-2.elb.amazonaws.com"
alb_zone_id            = "Z3POXM214Y7URM"

bastion_public_key_path = "C:/Users/USER/.ssh/id_rsa.pub"