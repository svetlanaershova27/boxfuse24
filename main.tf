required_providers {
  yandex = {
    source  = "yandex-cloud/yandex"
    version = "0.61.0"
  }
  docker = {
    source = "kreuzwerker/docker"
    version = "2.15.0"
  }
  artifactory = {
    source  = "registry.terraform.io/jfrog/artifactory"
    version = "2.2.7"
  }
}
provider "yandex" {
  token     = "<OAuth>"
  cloud_id  = "b1gmkpqp4nt4vvodlksj"
  folder_id = "b1gbimkvqiavfh3hsic4"
  zone      = "ru-central-1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87va5cc00gaq2f5qfb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/user1/data/meta1.txt")}"
  }
}
resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd87va5cc00gaq2f5qfb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/user1/data/meta2.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_container" "ubuntu" {
  name  = "foo"
  image = docker_image.ubuntu.latest
}

data "docker_registry_image" "ubuntu" {
  name = "ubuntu:precise"
}

resource "docker_image" "ubuntu" {
  name = data.docker_registry_image.ubuntu.name
}

data "docker_registry_image" "maven" {
  name = "maven:amazoncorretto"
}
resource "docker_image" "maven" {
  name = data.docker_registry_image.maven.name
}
data "docker_registry_image" "tomcat" {
  name = "tomcat:jre8-openjdk-slim"
}
resource "docker_image" "tomcat" {
  name = data.docker_registry_image.tomcat.name
}
provider "artifactory" {
  url = "https://hub.docker.com/"
  username = "svetlanaershova"
  password = "******"
}
resource "artifactory_remote_docker_repository" "myimage" {
  key                            = "myimage"
  enable_token_authentication    = true
  url                            = "https://hub.docker.com/repository/docker/svetlanaershova/myimage"
}
