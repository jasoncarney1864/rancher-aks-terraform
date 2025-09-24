resource "helm_release" "this" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  namespace        = var.namespace
  create_namespace = var.create_namespace

  values = var.sets != null ? [yamlencode(var.sets)] : []
}
