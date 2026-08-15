resource "aws_elasticache_cluster" "main" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = var.subnet_group_name
  security_group_ids   = var.security_group_ids

  tags = {
    Project = var.project_name
  }
}
