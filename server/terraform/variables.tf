variable "yc_cloud_id" {}

variable "yc_folder_id" {}

data "external" "server_keypair" {
  program = ["bash", "-c", <<-EOT
    private_key=$(wg genkey)
    public_key=$(echo "$private_key" | wg pubkey)
    echo "{\"private_key\": \"$private_key\", \"public_key\": \"$public_key\"}"
  EOT
  ]
}

data "external" "client_keypair" {
  program = ["bash", "-c", <<-EOT
    private_key=$(wg genkey)
    public_key=$(echo "$private_key" | wg pubkey)
    echo "{\"private_key\": \"$private_key\", \"public_key\": \"$public_key\"}"
  EOT
  ]
}