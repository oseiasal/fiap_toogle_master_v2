output "cluster_role_arn" {
  description = "ARN of the IAM Role for EKS Cluster"
  value       = var.create_iam_roles ? aws_iam_role.eks_cluster[0].arn : data.aws_iam_role.lab_role[0].arn
}

output "node_role_arn" {
  description = "ARN of the IAM Role for EKS Node Group"
  value       = var.create_iam_roles ? aws_iam_role.eks_nodes[0].arn : data.aws_iam_role.lab_role[0].arn
}

output "cluster_role_name" {
  description = "Name of the IAM Role for EKS Cluster"
  value       = var.create_iam_roles ? aws_iam_role.eks_cluster[0].name : var.lab_role_name
}

output "node_role_name" {
  description = "Name of the IAM Role for EKS Node Group"
  value       = var.create_iam_roles ? aws_iam_role.eks_nodes[0].name : var.lab_role_name
}
