locals {
  cluster_name = var.env == "dev" ? "kub-dev" : var.env == "preprod" ? "kub-preprod" : "kub-prod"
}