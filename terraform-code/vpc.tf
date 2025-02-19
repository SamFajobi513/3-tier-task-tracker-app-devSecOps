



provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------
# VPC (Virtual Private Cloud)
# ------------------------------------------
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

# ------------------------------------------
# Subnets for EKS (Public & Private)
# ------------------------------------------
resource "aws_subnet" "eks_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "eks_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# ------------------------------------------
# IAM Role for EKS Cluster
# ------------------------------------------
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# ------------------------------------------
# Create EKS Cluster
# ------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# ------------------------------------------
# IAM Role for Worker Nodes
# ------------------------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# ------------------------------------------
# EKS Worker Nodes (Node Group)
# ------------------------------------------
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-worker-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  tags = {
    "Name" = "eks-worker-nodes"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_worker_policy]
}



















# resource "aws_vpc" "vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = var.vpc-name
#   }
# }

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = var.igw-name
#   }
# }

# resource "aws_subnet" "public-subnet" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = var.subnet-name
#   }
# }

# resource "aws_route_table" "rt" {
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = var.rt-name
#   }
# }

# resource "aws_route_table_association" "rt-association" {
#   route_table_id = aws_route_table.rt.id
#   subnet_id      = aws_subnet.public-subnet.id
# }

# resource "aws_security_group" "security-group" {
#   vpc_id      = aws_vpc.vpc.id
#   description = "Allowing Jenkins, Sonarqube, SSH Access"

#   ingress = [
#     for port in [22, 8080, 9000, 9090, 80] : {
#       description      = "TLS from VPC"
#       from_port        = port
#       to_port          = port
#       protocol         = "tcp"
#       ipv6_cidr_blocks = ["::/0"]
#       self             = false
#       prefix_list_ids  = []
#       security_groups  = []
#       cidr_blocks      = ["0.0.0.0/0"]
#     }
#   ]

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = var.sg-name
#   }
# }
