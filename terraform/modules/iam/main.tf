# IAM Role for EKS Cluster (Control Plane)
resource "aws_iam_role" "eks_cluster" {
  count = var.create_iam_roles ? 1 : 0
  name  = "${lower(var.project_name)}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_nodes" {
  count = var.create_iam_roles ? 1 : 0
  name  = "${lower(var.project_name)}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = var.project_name
  }
}

# Standard EKS Node Policies
resource "aws_iam_role_policy_attachment" "node_worker" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Application Policy: Allows pods running on nodes to interact with DynamoDB and SQS
resource "aws_iam_policy" "pod_app_access" {
  count       = var.create_iam_roles ? 1 : 0
  name        = "${lower(var.project_name)}-pod-app-access-policy"
  description = "Allows EKS worker nodes and pods to interact with DynamoDB and SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeTable"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "node_app_access" {
  count      = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = aws_iam_policy.pod_app_access[0].arn
}

# Fallback data source for AWS Academy environments (when create_iam_roles = false)
data "aws_iam_role" "lab_role" {
  count = var.create_iam_roles ? 0 : 1
  name  = var.lab_role_name
}
