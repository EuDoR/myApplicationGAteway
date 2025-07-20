terraform {
    cloud {
        organization = "eud0r-1450"
        workspaces {
            name = "eud0r-wsTerraform"
        }
    }
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "4.37.0"
        }
    }
    
    required_version = ">= 1.0"
}