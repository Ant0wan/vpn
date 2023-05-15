terraform {
  required_providers {
    openvpn-cloud = {
      source  = "OpenVPN/openvpn-cloud"
      version = "0.0.10"
    }
  }
  required_version = "~> 1.3.0"
}

provider "openvpn-cloud" {
  # Configuration options
}


