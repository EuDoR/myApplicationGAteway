# main.tf
provider "azurerm" {
  features {
    
  }
}
# Create a Resource Group
resource "azurerm_resource_group" "MyResourceGroup" {
  name     = "ResourceGroupEud0r"
  location = "East US"
  
}

# Create a Virtual Network
resource "azurerm_virtual_network" "MyVNet" {
  name                = "myVNet"
  address_space       = ["10.0.0/16"]
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
  allocation_method   = "Dynamic" 
}
resource "azurerm_public_ip" "public_ip_docker" {
  name                = "PublicIPDocker"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  allocation_method   = "Dynamic"   
}
resource "azurerm_public_ip" "public_ip_otrasApps" {
  name                = "PublicIPOtrasApps"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  allocation_method   = "Dynamic"
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

# VMs
resource "azurerm_linux_virtual_machine" "vm_docker" {
  name                = "VMDocker"
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  location            = azurerm_resource_group.MyResourceGroup.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "12345678"
  network_interface_ids = [
    azurerm_network_interface.nic_docker.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
}

resource "azurerm_linux_virtual_machine" "vm_otrasApps" {
  name  = "VMOtrasApps"
  resource_group_name = azurerm_resource_group.MyResourceGroup.name
  location = azurerm_resource_group.MyResourceGroup.location
  size = "Standard_B1s"
  admin_username = "adminuser"
  admin_password = "12345678"
  network_interface_ids = [
    azurerm_network_interface.nic_otrasApps.id
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
