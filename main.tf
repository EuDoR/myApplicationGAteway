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
resource "azurerm_subnet" "subnet_otras" {
  name                 = "SubnetOtras"
  resource_group_name  = azurerm_resource_group.MyResourceGroup.name
  virtual_network_name = azurerm_virtual_network.MyVNet.name
  address_prefixes     = [var.subnet_otras_prefix]
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
resource "azurerm_public_ip" "public_ip_otras" {
  name                = "PublicIPOtras"
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
resource "azurerm_network_interface" "nic_otras" {
  name                = "NICOtras"
  location            = azurerm_resource_group.MyResourceGroup.location
  resource_group_name = azurerm_resource_group.MyResourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_otras.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_otras.id
  }
}



# resource "azurerm_linux_virtual_machine" "docker" {
#   name = "docker-vm"
# }