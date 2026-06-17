# ==============================================================================
# Site-to-Site VPN: AWS VPC <-> Azure VNet
# DMS(Aurora -> Azure MySQL DR 복제)가 공개 인터넷이 아닌 사설 터널을 사용하도록 연결
#
# 2단계 apply 필요 (Azure VPN Gateway 공개 IP는 먼저 생성해야 알 수 있음):
#   1단계: azure_vpn_gateway_ip = "" 인 상태로 apply -> 이 파일의 리소스는 전부 count=0
#          (Azure 측 azure-networking 모듈만 먼저 apply 해서 공개 IP 확보)
#   2단계: 확보한 Azure VPN Gateway 공개 IP를 azure_vpn_gateway_ip 변수에 입력 후 재apply
# ==============================================================================

resource "aws_vpn_gateway" "main" {
  count  = var.azure_vpn_gateway_ip != "" ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-vgw"
    Environment = var.environment
  }
}

resource "aws_customer_gateway" "azure" {
  count      = var.azure_vpn_gateway_ip != "" ? 1 : 0
  bgp_asn    = 65000
  ip_address = var.azure_vpn_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name        = "${var.project_name}-azure-cgw"
    Environment = var.environment
  }
}

resource "aws_vpn_connection" "to_azure" {
  count               = var.azure_vpn_gateway_ip != "" ? 1 : 0
  vpn_gateway_id      = aws_vpn_gateway.main[0].id
  customer_gateway_id = aws_customer_gateway.azure[0].id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name        = "${var.project_name}-to-azure-vpn"
    Environment = var.environment
  }
}

resource "aws_vpn_connection_route" "azure_cidr" {
  count                  = var.azure_vpn_gateway_ip != "" && var.azure_vnet_cidr != "" ? 1 : 0
  vpn_connection_id      = aws_vpn_connection.to_azure[0].id
  destination_cidr_block = var.azure_vnet_cidr
}

# DMS가 위치한 private 서브넷에서 Azure VNet 대역으로 가는 라우트
# 기존 0.0.0.0/0(NAT GW) 라우트보다 더 구체적인 prefix이므로 Azure 트래픽만 VGW로 우선 라우팅됨
resource "aws_route" "private_a_to_azure" {
  count                  = var.azure_vpn_gateway_ip != "" && var.azure_vnet_cidr != "" ? 1 : 0
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = var.azure_vnet_cidr
  gateway_id             = aws_vpn_gateway.main[0].id
}

resource "aws_route" "private_c_to_azure" {
  count                  = var.azure_vpn_gateway_ip != "" && var.azure_vnet_cidr != "" ? 1 : 0
  route_table_id         = aws_route_table.private_c.id
  destination_cidr_block = var.azure_vnet_cidr
  gateway_id             = aws_vpn_gateway.main[0].id
}

# ==============================================================================
# DB 서브넷 라우팅 테이블에도 Azure VPN 라우트 추가
# ==============================================================================
resource "aws_route" "db_to_azure" {
  count                  = var.azure_vpn_gateway_ip != "" && var.azure_vnet_cidr != "" ? 1 : 0
  route_table_id         = aws_route_table.db.id
  destination_cidr_block = var.azure_vnet_cidr
  gateway_id             = aws_vpn_gateway.main[0].id
}
