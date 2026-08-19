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

  # ⚙️ Capacidade & Tipos de Instância (Dev - Mais econômico)
  eks_instance_types    = ["t4g.small"] # Alternativas: ["t4g.micro"], ["t4g.medium"], ["t4g.large"]
  eks_desired_size      = 2            # Quantidade de worker nodes ativos
  eks_min_size          = 1
  eks_max_size          = 3
  rds_instance_class    = "db.t4g.small" # Alternativas: "db.t4g.micro", "db.t4g.medium"
  rds_allocated_storage = 20            # Armazenamento em GB
  redis_node_type       = "cache.t4g.small"
}
