terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.105.0"
    }
  }
}

provider "yandex" {
  token     = "asderbin_token_yandex"
  cloud_id  = "b1gflqftlca9jatlviqa"
  folder_id = "b1ggssofjksgcf4d46cl"
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "build_node" {
  name = "new1"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.ubuntu2004_15GB.id
  }
  network_interface {
    subnet_id = "e9b5gvivpqjj7upb4c9l"
    nat       = true
  }
  metadata = {
    user-data = "${file("./key.yml")}"
  }
  scheduling_policy {
    preemptible = true 
  }
  connection {
    type        = "ssh"
    user        = "asderbin"
    private_key = file("/root/.ssh/id_rsa")
    host        = yandex_compute_instance.default.network_interface.0.nat_ip_address
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update", 
      "sudo apt install mc -y",
      "sudo apt install ansible -y",
    ]
  }
}

resource "yandex_compute_instance" "app_node" {
  name = "new2"  
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.ubuntu2004_15GB.id
  }
  network_interface {
    subnet_id = "e9b5gvivpqjj7upb4c9l"  
    nat       = true
  }
  metadata = {
    user-data = "${file("./key.yml")}"
  }
  scheduling_policy {
    preemptible = true 
  }
  connection {
    type        = "ssh"
    user        = "asderbin"
    private_key = file("/root/.ssh/id_rsa")
    host        = yandex_compute_instance.additional.network_interface.0.nat_ip_address
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update", 
      "sudo apt install mc -y",
      ]
  }
}

data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_disk" "build_node_ubuntu2004_15GB" {
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = data.yandex_compute_image.ubuntu_image.id
  size     = 15
}
 resource "yandex_compute_disk" "app_node_ubuntu2004_15GB" {
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = data.yandex_compute_image.ubuntu_image.id
  size = 15
 }