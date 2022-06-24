
variable "dados_yaml" {}
locals {
  valores = yamldecode(file(var.dados_yaml))
}
// output "log" { value = local.valores }



terraform {
  backend "local" {
    path = "../terraform_internos/terraform.tfstate"
  }
}



provider "kubernetes" {
  config_context_cluster  = local.valores.nome_cluster           # qual o cluster que vais ser usado
  config_path             = local.valores.configuracao_cluster   # ficheiro de configuração acesso cluster
}

resource "kubernetes_namespace" "meus_recursos_de_namespaces" {
  for_each = toset(local.valores.meus_namespaces)
  metadata {
    name = each.key
  }
}
