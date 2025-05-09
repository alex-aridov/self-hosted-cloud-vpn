variable "server_password" {
  sensitive = true
}

variable "dns_token" {
  sensitive = true
}

variable "client_private_key" {
  sensitive = true
}

variable "server_private_key" {
  sensitive = true
}

variable "server_public_key" {}

variable "client_public_key" {}

variable "dns_host" {}

variable "yc_cloud_id" {}

variable "yc_folder_id" {}