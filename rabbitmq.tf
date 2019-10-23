provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.gcp_project}"
  region      = "${var.region}"
}


resource "google_compute_address" "sonarqubeip" {
  name   = "${var.rabbitmq_instance_ip_name}"
  region = "${var.rabbitmq_instance_ip_region}"
}


resource "google_compute_instance" "rabbitmq" {
  name         = "${var.instance_name}"
  machine_type = "n1-standard-2"
  zone         = "us-east1-b"

  tags = ["name", "rabbitmq", "http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  #scratch_disk {
  #}

  network_interface {
    network    = "${var.rabbitmqvpc}"
    subnetwork = "${var.rabbitmqsub}"
    access_config {
      // Ephemeral IP
      nat_ip = "${google_compute_address.rabbitmqip.address}"
    }
  }
  metadata = {
    name = "rabbitmq"
  }

  metadata_startup_script = "sudo apt-get update -y;sudo apt-get install git -y; sudo git clone https://github.com/Diksha86/rabbitmq.git; cd rabbitmq; sudo chmod 777 /rabbitmq/*; sudo sh rabbitmq.sh"
}
