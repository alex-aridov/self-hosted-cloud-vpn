terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.141.0"
    }
  }
}

provider "yandex" {
  cloud_id                 = "b1gg1uskjvst8kqebrd2"
  folder_id                = "b1glbm5j4foccsklnrrg"
  zone                     = "ru-central1-a"
  service_account_key_file = "key.json"
}