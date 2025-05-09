data "yandex_compute_image" "almalinux" {
  family = "almalinux-9"
}

resource "yandex_vpc_security_group" "vpn-sg" {
  name       = "vpn-security-group"
  network_id = yandex_vpc_network.vpn-net.id

  ingress {
    protocol       = "ICMP"
    description    = "Allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "UDP"
    description    = "WireGuard port"
    port           = 51820
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_compute_instance" "vpn-server" {
  name        = "vpn"
  platform_id = "standard-v3" //intel-ice-lake
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 1
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image_id = data.yandex_compute_image.almalinux.id # almalinux 9
      type     = "network-ssd"
      size     = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.vpn-subnet.id
    security_group_ids = [yandex_vpc_security_group.vpn-sg.id]
    nat                = true
  }

  metadata = {
    user-data = templatefile("${path.module}/template/cloud-init.yml.tpl", {
      server           = local.server
      wireguard_config = local.wireguard_config
    })
  }
}

output "external_ip" {
  value = yandex_compute_instance.vpn-server.network_interface.0.nat_ip_address
}