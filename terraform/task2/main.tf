# VARIABLES
variable "gce_ssh_user" {}
variable "gce_ssh_pub_key_file" {}
variable "credential_path" {}
variable "project_id" {}
variable "zone" {}
variable "region" {}

# PROVIDERS
provider "google" {
  credentials = file(var.credential_path)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# RESOURCES
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

# OUTPUT
output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}