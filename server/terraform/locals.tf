locals {
  server = {
    public_key  = data.external.server_keypair.result.public_key
    private_key = data.external.server_keypair.result.private_key
  }

  peers = [
    {
      public_key  = data.external.client_keypair.result.public_key
      private_key = data.external.client_keypair.result.private_key
      allowed_ips = "10.0.0.2/32"
    }
  ]

  wireguard_config = templatefile("${path.module}/template/wireguard.conf.tpl", {
    peers  = local.peers
    server = local.server
  })
}