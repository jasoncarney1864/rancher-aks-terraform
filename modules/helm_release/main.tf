resource "helm_release" "this" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  namespace        = var.namespace
  create_namespace = var.create_namespace

  dynamic "set" {
    for_each = var.sets
    content {
      name  = set.key
      value = set.value
    }
  }
}
