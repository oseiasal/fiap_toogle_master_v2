include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//"
}

inputs = {
  project_name     = "ToogleMaster-dev"
  region           = "us-east-1"
  db_password      = "DevSenhaMaster123!"
  create_iam_roles = true
  k8s_version      = "1.31"

  # ⚙️ Capacidade & Tipos de Instância (Dev - Mais econômico)
  eks_instance_types    = ["t3.small"] # Alternativas: ["t3.micro"], ["t3.medium"], ["t3.large"]
  eks_desired_size      = 2            # Quantidade de worker nodes ativos
  eks_min_size          = 1
  eks_max_size          = 3
  rds_instance_class    = "db.t3.small" # Alternativas: "db.t3.micro", "db.t3.medium"
  rds_allocated_storage = 20            # Armazenamento em GB
  redis_node_type       = "cache.t3.small"
}
