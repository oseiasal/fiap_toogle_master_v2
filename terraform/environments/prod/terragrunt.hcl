include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//"
}

inputs = {
  project_name     = "ToogleMaster-prod"
  region           = "us-east-1"
  db_password      = "ProdSenhaMasterSegura456#"
  create_iam_roles = true
  k8s_version      = "1.31"

  # ⚙️ Capacidade & Tipos de Instância (Prod - Alta Performance e Resiliência)
  eks_instance_types    = ["t3.medium"]
  eks_desired_size      = 3
  eks_min_size          = 2
  eks_max_size          = 5
  rds_instance_class    = "db.t3.medium"
  rds_allocated_storage = 50
  redis_node_type       = "cache.t3.medium"
}
