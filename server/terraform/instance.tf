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

locals {
  client_config = templatefile("${path.module}/template/client.conf.tpl", {
    client_private_key = local.peers.0.private_key
    client_ip          = "10.0.0.2/32"
    server_public_key  = local.server.public_key
    server_endpoint    = "${yandex_compute_instance.vpn-server.network_interface[0].nat_ip_address}:51820"
  })
}

resource "local_file" "wg_client_conf" {
  content  = local.client_config
  filename = "${path.module}/wg-client.conf"
}

output "external_ip" {
  value = yandex_compute_instance.vpn-server.network_interface.0.nat_ip_address
}

output "client_config_content" {
  value = local.client_config
  sensitive = true
}