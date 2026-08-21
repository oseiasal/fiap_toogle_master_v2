data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                        = "${lower(var.project_name)}-vpc"
    Project                                     = var.project_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${lower(var.project_name)}-igw"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# TIER 1: SUBNETS PÚBLICAS (DMZ / ALB / NAT GATEWAY)
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${lower(var.project_name)}-public-subnet-${count.index == 0 ? "a" : "b"}"
    Project                                     = var.project_name
    Tier                                        = "Public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -----------------------------------------------------------------------------
# TIER 2: SUBNETS PRIVADAS DE APLICAÇÃO (EKS NODES & REDIS)
# -----------------------------------------------------------------------------
resource "aws_subnet" "private_app" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${lower(var.project_name)}-private-app-subnet-${count.index == 0 ? "a" : "b"}"
    Project                                     = var.project_name
    Tier                                        = "Private-Application"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -----------------------------------------------------------------------------
# TIER 3: SUBNETS ISOLADAS DE BANCO DE DADOS (RDS POSTGRESQL)
# -----------------------------------------------------------------------------
resource "aws_subnet" "isolated_db" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.isolated_db_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${lower(var.project_name)}-isolated-db-subnet-${count.index == 0 ? "a" : "b"}"
    Project = var.project_name
    Tier    = "Database-Isolated"
  }
}

# -----------------------------------------------------------------------------
# NAT GATEWAY (Saída segura à internet para os nós privados do EKS)
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "${lower(var.project_name)}-nat-eip"
    Project = var.project_name
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name    = "${lower(var.project_name)}-nat-gw"
    Project = var.project_name
  }

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# TABELAS DE ROTAS E ASSOCIAÇÕES
# -----------------------------------------------------------------------------
# 1. Rota Pública -> Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${lower(var.project_name)}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 2. Rota Privada de Aplicação -> NAT Gateway
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name    = "${lower(var.project_name)}-private-app-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# 3. Rota Isolada de Banco -> Apenas tráfego local da VPC (sem saída para internet)
resource "aws_route_table" "isolated_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${lower(var.project_name)}-isolated-db-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "isolated_db" {
  count          = 2
  subnet_id      = aws_subnet.isolated_db[count.index].id
  route_table_id = aws_route_table.isolated_db.id
}

# -----------------------------------------------------------------------------
# SECURITY GROUPS HARDENED POR CAMADA (Zero Trust)
# -----------------------------------------------------------------------------

# 1. SG para o Application Load Balancer (Tier Público)
resource "aws_security_group" "alb" {
  name        = "${lower(var.project_name)}-alb-sg"
  description = "Security group for public ALB ingress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP Public Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Public Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound to private nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${lower(var.project_name)}-alb-sg"
    Project = var.project_name
  }
}

# 2. SG para os Worker Nodes do EKS (Tier Privado de Aplicação)
resource "aws_security_group" "eks_nodes" {
  name        = "${lower(var.project_name)}-eks-nodes-sg"
  description = "Security group for EKS worker nodes and pods"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Traffic from public ALB"
    from_port       = 8001
    to_port         = 8005
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "NodePort traffic from public ALB"
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Internal Node/Pod communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic (via NAT Gateway)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${lower(var.project_name)}-eks-nodes-sg"
    Project = var.project_name
  }
}

# 3. SG para os Bancos RDS PostgreSQL (Tier Isolado de Dados)
resource "aws_security_group" "rds" {
  name        = "${lower(var.project_name)}-rds-sg"
  description = "Security group for RDS PostgreSQL - only accepts connections from EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from VPC and EKS Nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    description = "Allow local outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name    = "${lower(var.project_name)}-rds-sg"
    Project = var.project_name
  }
}

# 4. SG para o ElastiCache Redis (Tier Privado de Aplicação)
resource "aws_security_group" "redis" {
  name        = "${lower(var.project_name)}-redis-sg"
  description = "Security group for ElastiCache Redis - only accepts connections from EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from VPC and EKS Nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = [aws_security_group.eks_nodes.id]
  }


  egress {
    description = "Allow local outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name    = "${lower(var.project_name)}-redis-sg"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# SUBNET GROUPS (RDS & ELASTICACHE)
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name        = "${lower(var.project_name)}-db-subnet-group"
  subnet_ids  = aws_subnet.isolated_db[*].id
  description = "Database subnet group restricted to isolated database subnets"

  tags = {
    Name    = "${lower(var.project_name)}-db-subnet-group"
    Project = var.project_name
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name        = "${lower(var.project_name)}-cache-subnet-group"
  subnet_ids  = aws_subnet.private_app[*].id
  description = "ElastiCache subnet group placed in private application subnets"

  tags = {
    Name    = "${lower(var.project_name)}-cache-subnet-group"
    Project = var.project_name
  }
}
