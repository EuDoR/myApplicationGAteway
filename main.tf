# main.tf
provider "azurerm" {
  features {}
  # subscription_id = "67f32328-0f4e-4cbd-9f39-c4eef480cad8"
}
# Create a Resource Group
resource "azurerm_resource_group" "MyResourceGroup" {
  name     = "ResourceGroupEud0r"
  location = "East US"

}

# Create a Virtual Network
resource "azurerm_virtual_network" "MyVNet" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
}

# Create subnets for Application Gateway, Docker, and other resources
resource "azurerm_subnet" "subnet_ag" {
  name                 = "SubnetAG"
  resource_group_name  = azurerm_resource_group.MyResourceGroup.name
  virtual_network_name = azurerm_virtual_network.MyVNet.name
  address_prefixes     = [var.subnet_ag_prefix]
}
resource "azurerm_subnet" "subnet_docker" {
  name                 = "SubnetDocker"
  resource_group_name  = azurerm_resource_group.MyResourceGroup.name
  virtual_network_name = azurerm_virtual_network.MyVNet.name
  address_prefixes     = [var.subnet_docker_prefix]
}
resource "azurerm_subnet" "subnet_otrasapps" {
  name                 = "SubnetOtrasapps"
  resource_group_name  = azurerm_resource_group.MyResourceGroup.name
  virtual_network_name = azurerm_virtual_network.MyVNet.name
  address_prefixes     = [var.subnet_otrasApps_prefix]
}

# Create Public IPs for Application Gateway, Docker, and other resources
resource "azurerm_public_ip" "public_ip_ag" {
  name                = "PublicIPAG"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  allocation_method   = "Static"
}
resource "azurerm_public_ip" "public_ip_docker" {
  name                = "PublicIPDocker"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  allocation_method   = "Static"
}
resource "azurerm_public_ip" "public_ip_otrasApps" {
  name                = "PublicIPOtrasApps"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  allocation_method   = "Static"
}

# Create Network Interfaces for Application Gateway, Docker, and other resources
resource "azurerm_network_interface" "nic_docker" {
  name                = "NICDocker"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_docker.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_docker.id
  }
}
resource "azurerm_network_interface" "nic_otrasApps" {
  name                = "NICOtrasApps"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_otrasapps.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_otrasApps.id
  }
}

# Create Network Security Groups for Docker and other applications
resource "azurerm_network_security_group" "nsg_vms" {
  name                = "NSGVMS"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "8443", "8081", "8082", "8036"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow_Artifactory_Web_and_API"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5000"]
    source_address_prefix      = "Internet" # Ajusta esto a tu rango IP seguro
    destination_address_prefix = "*"
  }
}

# Associate Network Security Groups with subnets
resource "azurerm_subnet_network_security_group_association" "dockerSubnetNSG" {
  subnet_id                 = azurerm_subnet.subnet_docker.id
  network_security_group_id = azurerm_network_security_group.nsg_vms.id
}

resource "azurerm_subnet_network_security_group_association" "otrasAppsSubnetNSG" {
  subnet_id                 = azurerm_subnet.subnet_otrasapps.id
  network_security_group_id = azurerm_network_security_group.nsg_vms.id
}

# Create Virtual Machines for Docker and other applications
# resource "azurerm_linux_virtual_machine" "vm_docker" {
#   name                            = "VMDocker"
#   resource_group_name             = azurerm_resource_group.MyResourceGroup.name
#   location                        = azurerm_resource_group.MyResourceGroup.location
#   size                            = "Standard_B1ms"
#   admin_username                  = "adminuser"
#   admin_password                  = "@dmin1234"
#   disable_password_authentication = false
#   network_interface_ids = [
#     azurerm_network_interface.nic_docker.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }



#     # publisher = "RedHat"
#     # offer     = "RHEL"          # Oferta base de Red Hat
#     # sku       = "8-lvm"         # SKU de RHEL 8 (más ligero que 9)
#     # version   = "latest"    
    
#     # publisher = "Canonical"
#     # offer     = "0001-com-ubuntu-server-jammy"
#     # sku       = "22_04-lts"
#     # version   = "latest"
#   # }

#   # custom_data = filebase64("scripts/dockerinstallRedhat.sh")
# }

resource "azurerm_linux_virtual_machine" "vm_otrasApps" {
  name                            = "VMOtrasApps"
  resource_group_name             = azurerm_resource_group.MyResourceGroup.name
  location                        = azurerm_resource_group.MyResourceGroup.location
  # size                            = "Standard_B1ms"
  size                            = "Standard_B2s"  # Tamaño ajustado para más recursos
  admin_username                  = "adminuser"
  admin_password                  = "@dmin1234"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_otrasApps.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"          # Oferta base de Red Hat
    sku       = "8-lvm"         # SKU de RHEL 8 (más ligero que 9)
    version   = "latest"

    # publisher = "Canonical"
    # offer     = "0001-com-ubuntu-server-jammy"
    # sku       = "22_04-lts"
    # version   = "latest"
  }
  custom_data = filebase64("scripts/artifactoryredhatold.sh")
  # custom_data   = filebase64("scripts/jenkinsOldRedhat.sh")
}

# Create Local Variables for Application Gateway
locals {
  backend_address_pool_name_docker = "${azurerm_virtual_network.MyVNet.name}-APbeap-docker"
  backend_address_pool_name_otras  = "${azurerm_virtual_network.MyVNet.name}-APbeap-otrasapps"
  frontend_port_name               = "${azurerm_virtual_network.MyVNet.name}-APfeport"
  frontend_ip_configuration_name   = "${azurerm_virtual_network.MyVNet.name}-APfeipconfig"
  http_settings_name_docker        = "${azurerm_virtual_network.MyVNet.name}-APbe-htst-docker"
  http_settings_name_otras         = "${azurerm_virtual_network.MyVNet.name}-APbe-htst-otrasapps"
  listener_name                    = "${azurerm_virtual_network.MyVNet.name}-APlistener"
  request_routing_rule_name        = "${azurerm_virtual_network.MyVNet.name}-APreqroutingrule"
  url_path_map_name                = "${azurerm_virtual_network.MyVNet.name}-APurlpathmap"
  health_probe_name_docker         = "${azurerm_virtual_network.MyVNet.name}-APhealthprobe-docker"
  health_probe_name_otras          = "${azurerm_virtual_network.MyVNet.name}-APhealthprobe-otrasapps"
}


#Create Application Gateway
# resource "azurerm_application_gateway" "application_gateway" {
#   name                = "MyApplicationGateway"
#   location            = azurerm_resource_group.MyResourceGroup.location
#   resource_group_name = azurerm_resource_group.MyResourceGroup.name

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "gatewayIpConfig"
#     subnet_id = azurerm_subnet.subnet_ag.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.public_ip_ag.id
#   }

#   backend_address_pool {
#     name = local.backend_address_pool_name_docker
#   }
#   backend_address_pool {
#     name = local.backend_address_pool_name_otras
#   }

#   backend_http_settings {
#     name                  = local.http_settings_name_docker
#     cookie_based_affinity = "Disabled"
#     port                  = 8081
#     protocol              = "Http"
#     request_timeout       = 20
#   }
#   backend_http_settings {
#     name                  = local.http_settings_name_otras
#     cookie_based_affinity = "Disabled"
#     port                  = 8080
#     protocol              = "Http"
#     request_timeout       = 20
#     pick_host_name_from_backend_address = true
#     probe_name = local.health_probe_name_otras

#   }

#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   url_path_map {
#     name                = local.url_path_map_name
#     default_backend_address_pool_name  = local.backend_address_pool_name_docker
#     default_backend_http_settings_name = local.http_settings_name_docker

#     path_rule {
#       name                       = "otrasAppsPathRule"
#       paths                      = ["/otras*"]
#       backend_address_pool_name  = local.backend_address_pool_name_otras
#       backend_http_settings_name = local.http_settings_name_otras
#     }
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     priority                   = 100
#     rule_type                  = "PathBasedRouting"
#     url_path_map_name          = local.url_path_map_name
#     http_listener_name         = local.listener_name
#   }
#   probe {
#     name                = local.health_probe_name_otras
#     protocol            = "Http"
#     path                = "/otras/login"
#     interval            = 30
#     timeout             = 30
#     unhealthy_threshold = 3
#     pick_host_name_from_backend_http_settings =  true
#     match {
#       status_code = ["200-403"]
#     }

#   }

#   tags = {
#     environment = "pruebas"
#   }
# }
