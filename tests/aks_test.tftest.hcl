run "verify_aks_cluster" {
  command = apply

  module {
    source = "./example"
  }

  assert {
    condition     = module.aks.cluster_id != null
    error_message = "Cluster ID should not be null"
  }

  assert {
    condition     = module.aks.kube_config != null
    error_message = "Kube config should not be null"
  }

  assert {
    condition     = module.aks.cluster_endpoint != null
    error_message = "Cluster endpoint should not be null"
  }

  assert {
    condition     = module.aks.cluster_identity != null
    error_message = "Cluster identity should not be null"
  }
} 