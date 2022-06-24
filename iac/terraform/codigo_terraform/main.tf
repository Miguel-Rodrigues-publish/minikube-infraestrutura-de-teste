variable "dados_yaml" {}

locals {
  valores = yamldecode(file(var.dados_yaml))
}

output "log" { value = local.valores }

provider "kubernetes" {
  config_context_cluster   = local.valores.nome_cluster   # qual o cluster que vais ser usado
}

resource "kubernetes_namespace" "meus_recursos_de_namespaces" {
  for_each = toset(local.valores.meus_namespaces)
  metadata {
    name = each.key
  }
}
