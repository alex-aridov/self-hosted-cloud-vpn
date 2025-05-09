resource "yandex_vpc_network" "vpn-net" {
  name = "vpn-network"
}

resource "yandex_vpc_subnet" "vpn-subnet" {
  name           = "vpn-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpn-net.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}