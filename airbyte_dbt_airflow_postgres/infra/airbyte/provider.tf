// Airbyte Terraform provider documentation: https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs

terraform {
  required_providers {
    airbyte = {
      source = "airbytehq/airbyte"
      version = "0.6.5"
    }
  }
}

provider "airbyte" {
  // If running locally (Airbyte OSS) with docker-compose using the airbyte-proxy, 
  // include the actual password/username you've set up (or use the defaults below)
  username = "akh.vyas@gmail.com"
  password = "XOwgHUkY0jPjVduuQEW6i1slXz2ogCFI"
  
  // if running locally (Airbyte OSS), include the server url to the airbyte-api-server
  server_url = "http://localhost:8000/api/public/v1"
}