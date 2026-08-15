module "iam" {
  source = "./modules/iam"

  project_name     = var.project_name
  create_iam_roles = var.create_iam_roles
  lab_role_name    = var.lab_role_name
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
}

module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  cluster_name       = "toogle-cluster"
  node_group_name    = "toogle-nodes"
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  cluster_version    = var.k8s_version
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.network.security_group_id]
}

module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  db_password          = var.db_password
  db_subnet_group_name = module.network.db_subnet_group_name
  security_group_ids   = [module.network.security_group_id]
  publicly_accessible  = true
}

module "redis" {
  source = "./modules/redis"

  project_name       = var.project_name
  cluster_id         = "toogle-redis"
  subnet_group_name  = module.network.elasticache_subnet_group_name
  security_group_ids = [module.network.security_group_id]
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
