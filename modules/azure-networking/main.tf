# ==============================================================================
# Azure VNet + VPN Gateway (AWS S2S VPN 연결의 Azure측 절반)
#
# 2단계 apply:
#   1단계: 이 모듈만 먼저 apply -> azurerm_virtual_network_gateway 생성 (30~45분 소요)
#          -> vpn_gateway_public_ip output 확인
#   2단계: 해당 IP를 AWS networking 모듈의 azure_vpn_gateway_ip 변수에 입력 후 전체 재apply
#          -> aws_vpn_tunnel1/2_address가 채워지면 이 모듈의 LNG/Connection이 자동 생성됨
#
# 이중화: AWS VPN Connection은 터널 2개(tunnel1, tunnel2)를 기본 제공함.
# Azure 쪽엔 BGP가 없으므로(static routing) 터널마다 별도 Local Network Gateway +
# Connection을 만들어 같은 Azure VPN Gateway에 연결 -> 터널 1개가 죽어도 나머지로 우회
# ==============================================================================

resource "azurerm_resource_group" "vpn" {
  name     = "${var.project_name}-${var.environment}-vpn-rg"
  location = var.azure_location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-${var.environment}-vnet"
  address_space       = [var.azure_vnet_cidr]
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
}

# Azure 고정 명칭 - "GatewaySubnet" 외 다른 이름 사용 불가
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.vpn.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

resource "azurerm_public_ip" "vpn_gw" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.project_name}-${var.environment}-vpngw-ip"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_virtual_network_gateway" "main" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.project_name}-${var.environment}-vpngw"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1AZ"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.vpn_gw[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# AWS측 VPN 터널 정보가 전달된 후에만 생성 (2단계 apply)

# 터널 1
resource "azurerm_local_network_gateway" "aws_tunnel1" {
  count               = var.enable_vpn_gateway && var.aws_vpn_tunnel1_address != "" ? 1 : 0
  name                = "${var.project_name}-${var.environment}-aws-lng-1"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  gateway_address     = var.aws_vpn_tunnel1_address
  address_space       = [var.aws_vpc_cidr]
}

resource "azurerm_virtual_network_gateway_connection" "to_aws_tunnel1" {
  count               = var.enable_vpn_gateway && var.aws_vpn_tunnel1_address != "" ? 1 : 0
  name                = "${var.project_name}-${var.environment}-to-aws-1"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel1[0].id
  shared_key                 = var.aws_vpn_tunnel1_preshared_key
}

# 터널 2 (이중화 - 터널 1 장애 시 우회 경로)
resource "azurerm_local_network_gateway" "aws_tunnel2" {
  count               = var.enable_vpn_gateway && var.aws_vpn_tunnel2_address != "" ? 1 : 0
  name                = "${var.project_name}-${var.environment}-aws-lng-2"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  gateway_address     = var.aws_vpn_tunnel2_address
  address_space       = [var.aws_vpc_cidr]
}

resource "azurerm_virtual_network_gateway_connection" "to_aws_tunnel2" {
  count               = var.enable_vpn_gateway && var.aws_vpn_tunnel2_address != "" ? 1 : 0
  name                = "${var.project_name}-${var.environment}-to-aws-2"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel2[0].id
  shared_key                 = var.aws_vpn_tunnel2_preshared_key
}

# AWS-Azure 간 자원 생성 시 발생하는 상호 IP 의존성(순환 참조) 문제를 해결하기 위해 
# [1단계: VNet 및 게이트웨이 본체 생성 ➡️ 2단계: AWS 터널 주소 주입 후 LNG 및 IPsec 커넥션 완성] 형태로 배포 단계 격리
resource "azurerm_subnet" "app" {
  name                 = "${var.project_name}-${var.environment}-app-subnet"
  resource_group_name  = azurerm_resource_group.vpn.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_cidr]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "mysql" {
  name                 = "${var.project_name}-${var.environment}-mysql-subnet"
  resource_group_name  = azurerm_resource_group.vpn.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.mysql_subnet_cidr]

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.project_name}.private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.vpn.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.project_name}-${var.environment}-mysql-dns-link"
  resource_group_name   = azurerm_resource_group.vpn.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# ==============================================================================
# 사용자 요청: MySQL 서브넷용 별도 NSG 생성
# ==============================================================================
resource "azurerm_resource_group" "mysql_nsg" {
  name     = "team-train-prod-mysql-nsg"
  location = "koreacentral"
}

resource "azurerm_network_security_group" "mysql" {
  name                = "team-train-prod-mysql-nsg"
  location            = azurerm_resource_group.mysql_nsg.location
  resource_group_name = azurerm_resource_group.mysql_nsg.name

  security_rule {
    name                       = "Allow-MySQL-from-AWS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "mysql" {
  subnet_id                 = azurerm_subnet.mysql.id
  network_security_group_id = azurerm_network_security_group.mysql.id
}
