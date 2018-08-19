provider "google" {
  credentials = "${var.gce_credentials}"
  region = "${var.region}"
  version = "~> 1.16"
}

provider "random" {
  version = "~> 2.0"
}

provider "null" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

module "project" {
  source = "./modules/project"
  project_name = "${var.project_name}"
  region = "${var.region}"
  billing_account = "${var.billing_account}"
  organization_id = "${var.organization_id}"
  dns_name = "${var.dns_name}"
}

module "gke" {
  source = "./modules/gke"
  project_id = "${module.project.project_id}"
  region = "${var.region}"
  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"
}

module "k8s" {
  source = "./modules/k8s"
  k8s_host = "${module.gke.k8s_host}"
  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"
  gce_credentials = "${var.gce_credentials}"
  gke_node_pool_ready = "${module.gke.gke_node_pool_cluster}"
}
