terraform {
  required_version = ">1.0.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

resource "digitalocean_droplet" "kubenews" {
  image    = var.imagem
  name     = var.nome_server_01
  region   = var.regiao
  size     = var.size_server
  ssh_keys = [data.digitalocean_ssh_key.minha_chave.id]
  tags = [
    "kubedev"
  ]
}

data "digitalocean_ssh_key" "minha_chave" {
  name = "kubedev"
}

output "droplet_ip" {
  value = digitalocean_droplet.kubenews.ipv4_address
}

provider "digitalocean" {
  token = var.token
}
