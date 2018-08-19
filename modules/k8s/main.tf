resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "cat > ${path.module}/kubeconfig <<EOL\n${data.template_file.kubeconfig.rendered}\nEOL"
  }
}

resource "null_resource" "gke_ready" {
  triggers {
    random = "${uuid()}"
  }

  depends_on = [
    "null_resource.kubeconfig"
  ]

  provisioner "local-exec" {
    // Workaround to dependens on GKE node pool creation
    command = "echo ${var.gke_node_pool_ready}"
  }

  provisioner "local-exec" {
    command = "${local.kubectl} cluster-info"
  }
}

resource "null_resource" "sample_app" {
  depends_on = [
    "null_resource.gke_ready"
  ]

  provisioner "local-exec" {
    command = "${local.kubectl} run web --image=gcr.io/google-samples/hello-app:1.0 --port=8080 || true"
  }

  provisioner "local-exec" {
    command = "${local.kubectl} expose deployment web --target-port=8080 --type=NodePort || true"
  }

  provisioner "local-exec" {
    command = "${local.kubectl} apply -f ${path.module}/ingress.yaml"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "${local.kubectl} delete deployment/web svc/web ingress/web"
  }
}

resource "null_resource" "external_dns" {

  // disable external-dns resource creation
  count = 0

  depends_on = [
    "null_resource.gke_ready"
  ]

  provisioner "local-exec" {
    command = "${local.kubectl} create secret generic google-cloud-key --from-file=key.json=${var.gce_credentials} || true"
  }

  provisioner "local-exec" {
    command = "${local.kubectl} apply -f ${path.module}/external-dns.yaml"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "${local.kubectl} delete secret/google-cloud-key"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "${local.kubectl} delete -f ${path.module}/external-dns.yaml"
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/kubeconfig.yaml")}"

  vars {
    k8s_host = "${var.k8s_host}"
    k8s_username = "${var.k8s_username}"
    k8s_password = "${var.k8s_password}"
  }
}

locals {
  kubectl = "kubectl --kubeconfig=${path.module}/kubeconfig"
}
