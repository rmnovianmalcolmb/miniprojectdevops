# ============================================================
# terraform.tfvars — Environment Configuration
# ============================================================

location     = "eastasia"
project_name = "concert-ticketing"
environment  = "dev"

# Networking
vnet_address_space    = ["10.0.0.0/16"]
subnet_address_prefix = "10.0.1.0/24"

# SSH access — restrict to specific IP in production
# admin_source_ip = "203.0.113.10/32"
admin_source_ip = "*"

# Resource tags
tags = {
  Project     = "concert-ticketing-infra"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Course      = "DevOps-MiniProject"
}

# Virtual Machine configuration
admin_username = "azureuser"
vm_size        = "Standard_B2as_v2"

admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFVE2GyAvumw5uvjulcKykbPHHbq1BhrDngDjXniuelQkeODUhasXiEnymGmyOFz+mCztVSASQ4voDhFMASMQsp88TX/Ak8OMTRR9eHloeYfJABB3gX3pjIsJ3ozMgfQWiCJUPauAcTMsCtecKx1xNuwurhh3uROo+H+WqqmuttbjDRkEDF1DzkEGa/h8BLgphomJi+ds7/8ZUqC4uqfcfsVFIsWa0jFyV7GVCHkOofi3sZDzXkmYlqspgMrGlYTW6QEYGILX+CkHL/B4eWKttX3/mXctNFxehhZ6ePtnleHbOJN/08C0Q1nX2ZwX7yFzqn8cFvsP7BboVtM6N5mZjdf+8j819/u6pxxDn9tRPXNPaJWx3goP9y2JJEmJM7GgNaG3moCbMq1OQHP/SqGE7VPXsGUBG3vXiawrXu9P81+3z92fzzVBHO6bJ3fl/rTKk6yli07O9NtcbOYQ4OKlotl67jUtQIZm/lXrDn6Aj1RP+qPDOfOo0v30L3fgy52dwoSHwllGbowAbUFbA41Ipudfz+USSDCJM7fc1ucYwlQsvUuLoBJUTD+cevQn0HbfxWArOCoADsJGwUEpspngjDbwo6m+3vA7JUIcRyuczF1N8yCDZ/WRUN0bgc8w3LZgaPteuGXYDols4v3KS+SLgiHffRV2bhBhRyduuXukFWQ== devops-miniproject"
