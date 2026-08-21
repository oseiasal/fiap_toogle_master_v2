include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//"
}

inputs = {
  project_name     = "ToogleMaster-dev"
  region           = "us-east-1"
  # db_password      = "DevSenhaMaster123!"
  create_iam_roles = true
  k8s_version      = "1.31"

  # ⚙️ Capacidade & Tipos de Instância (Dev - Arquitetura x86_64 Intel/AMD)
  eks_instance_types    = ["t3.small"]
  eks_ami_type          = "AL2023_x86_64_STANDARD"
  eks_desired_size      = 2
  eks_min_size          = 1
  eks_max_size          = 3
  rds_instance_class    = "db.t4g.small"
  rds_allocated_storage = 20
  redis_node_type       = "cache.t4g.small"
}


