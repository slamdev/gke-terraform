terraform {
  backend "gcs" {
    // configs come from backend.tfvars
  }
}

module "gke_example" {
  source = ".."
  gce_credentials = "${var.gce_credentials}"
  organization_id = "${var.organization_id}"
  billing_account = "${var.billing_account}"
  project_name = "${var.project_name}"
  region = "${var.region}"
  dns_name = "${var.dns_name}"
  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"
}
