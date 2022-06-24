
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
