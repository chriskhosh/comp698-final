terraform {
 backend "gcs" {
   project = "comp698-cek1020"
   bucket  = "comp698-cek1020-terraform-state"
   prefix  = "terraform-state-final"
 }
}
provider "google" {
  region = "us-central1"
  project = "comp698-cek1020"
}
resource "google_storage_bucket" "image-store" {
  project  = "comp698-cek1020"
  name     = "bucket-three3"
  location = "us-central1"
}
resource "google_compute_instance_template" "instance_template_final_staging" {
  name_prefix  = "instancetemplatefinalstaging-"
  machine_type = "f1-micro"
  region       = "us-central1"

  tags = ["http-server"]

  // boot disk
  disk {
    source_image = "cos-cloud/cos-stable"
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }

  metadata {
      gce-container-declaration = <<EOF
  spec:
    containers:
      - image: 'gcr.io/comp698-cek1020/github-chriskhosh-comp698-final:586d8d6b8c954f76ce4d2a81de35f8e59d04bcd3'
        name: service-container
        stdin: false
        tty: false
    restartPolicy: Always
  EOF
  }
}

resource "google_compute_instance_group_manager" "instance_group_manager_final_staging" {
  name               = "instance-group-manager-final-staging"
  instance_template  = "${google_compute_instance_template.instance_template_final_staging.self_link}"
  base_instance_name = "tf-server-final-staging"
  zone               = "us-central1-a"
  target_size        = "1"
}
