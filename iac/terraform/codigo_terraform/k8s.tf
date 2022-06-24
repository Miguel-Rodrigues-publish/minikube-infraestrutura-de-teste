
provider "kubernetes" {
  config_context_cluster  = local.valores.nome_cluster           # qual o cluster que vais ser usado
  config_path             = local.valores.configuracao_cluster   # ficheiro de configuração acesso cluster
}
