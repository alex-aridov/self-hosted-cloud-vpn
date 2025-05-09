locals {
  server = {
    public_key  = var.server_public_key
    private_key = var.server_private_key
    password    = var.server_password
    dns = {
      token = var.dns_token
      host  = var.dns_host
    }
  }

  peers = [
    {
      public_key  = var.client_public_key
      private_key = var.client_private_key
      allowed_ips = "10.0.0.2/32"
    }
  ]

  wireguard_config = templatefile("${path.module}/template/wireguard.conf.tpl", {
    peers  = local.peers
    server = local.server
  })
}