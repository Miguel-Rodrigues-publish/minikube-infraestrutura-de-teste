resource "kubernetes_namespace" "meus_recursos_de_namespaces" {
  for_each = toset(local.valores.meus_namespaces)
  metadata {
    name = each.key
  }
}
