module "bootstrap" {
  source = "./bootstrap"
}

# VPC # יוצר את ה vpc עם dns 
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main-vpc"
  }
}
# חיבוריות לאינטרנט עבור ה public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}
# מספק כתובת ip ל-NAT Gateway ומאפשר לנודים גישה לאינטרנט
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
# משמש כדרך ל private subnet לקבל עדכונים
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.igw]
}
# הגדרת ה dns
resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
}
# הגדרות ה-dhcp של ה-vpc
resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}

# Subnets-תתי הרשתות
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name                                            = "public-subnet"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-2b"
  tags = {
    Name                                            = "private-subnet"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

# Route Tables-טבלאות הניתוב (public שולח ניתוב לinternetgateway),(private שולח תעבורה לnat gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

# EKS Cluster הגדרת הקלאסטר כולל שני נודים שיתפקדו כec2-t3.medium שרצים בשני תתי הרשתות
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name = "eks-cluster"
  }
}

# EKS Node Groups
resource "aws_eks_node_group" "node_group_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node-group-public"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.public_subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    "Name" = "node-group-public"
    "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}" = "owned"
  }
}

resource "aws_eks_node_group" "node_group_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node-group-private"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    "Name" = "node-group-private"
    "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster.name}" = "owned"
  }
}

# ECR Repository 'הגדרת רפו עבור אחסון האימג
resource "aws_ecr_repository" "flask_app_ecr" {
  name = "flask-app-repository"
}


