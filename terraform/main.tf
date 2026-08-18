module "iam" {
  source = "./modules/iam"

  project_name     = var.project_name
  create_iam_roles = var.create_iam_roles
  lab_role_name    = var.lab_role_name
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  cluster_name = "toogle-cluster"
}

module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  cluster_name       = "toogle-cluster"
  node_group_name    = "toogle-nodes"
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  cluster_version    = var.k8s_version
  subnet_ids         = module.network.private_app_subnet_ids
  security_group_ids = [module.network.eks_nodes_security_group_id]
  instance_types     = var.eks_instance_types
  desired_size       = var.eks_desired_size
  min_size           = var.eks_min_size
  max_size           = var.eks_max_size
}

module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  db_password          = var.db_password
  db_subnet_group_name = module.network.db_subnet_group_name
  security_group_ids   = [module.network.rds_security_group_id]
  publicly_accessible  = false
  instance_class       = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage
  multi_az             = var.rds_multi_az
}

module "redis" {
  source = "./modules/redis"

  project_name       = var.project_name
  cluster_id         = "toogle-redis"
  node_type          = var.redis_node_type
  subnet_group_name  = module.network.elasticache_subnet_group_name
  security_group_ids = [module.network.redis_security_group_id]
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  table_name   = "analytics_events"
}

module "sqs" {
  source = "./modules/sqs"

  project_name = var.project_name
  queue_name   = "toogle-events"
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  services = [
    "analytics-service",
    "auth-service",
    "evaluation-service",
    "flag-service",
    "targeting-service"
  ]
}
