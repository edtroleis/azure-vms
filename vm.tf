resource "azurerm_availability_set" "availability-set" {
  name                = "availability-set"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "network-interface" {
  count               = var.vm_number
  name                = "network-interface-${count.index}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.example_public_ip.*.id, count.index)
  }
}

# try connect
resource "azurerm_public_ip" "example_public_ip" {
  count               = var.vm_number
  name                = "vNet-${format("%02d", count.index)}-PublicIP"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  allocation_method   = "Static"
  tags = {
    environment = "Test"
  }
}

resource "azurerm_windows_virtual_machine" "virtual-machine" {
  count               = var.vm_number
  name                = "vm-${count.index}"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Troleis$$"
  availability_set_id = azurerm_availability_set.availability-set.id
  # network_interface_ids = [
  # azurerm_network_interface.network-interface.id,
  # ]
  network_interface_ids = [element(azurerm_network_interface.network-interface.*.id, count.index)]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Creating resource NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    "Owner"       = var.owner
    "Project"     = var.project
    "Environment" = var.environment
  }
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}







# https://medium.com/@yoursshaan2212/terraform-to-provision-multiple-azure-virtual-machines-fab0020b4a6e

# # Create a virtual network within the resource group
# resource "azurerm_virtual_network" "example_vnet" {
#   name                = "${var.resource_prefix}-vnet"
#   resource_group_name = azurerm_resource_group.example_rg.name
#   location            = var.node_location
#   address_space       = var.node_address_space
# }

# # Create a subnets within the virtual network
# resource "azurerm_subnet" "example_subnet" {
#   name                 = "${var.resource_prefix}-subnet"
#   resource_group_name  = azurerm_resource_group.example_rg.name
#   virtual_network_name = azurerm_virtual_network.example_vnet.name
#   address_prefix       = var.node_address_prefix
# }
# # Create Linux Public IP
# resource "azurerm_public_ip" "example_public_ip" {
#   count = var.node_count
#   name  = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
#   #name = "${var.resource_prefix}-PublicIP"
#   location            = azurerm_resource_group.example_rg.location
#   resource_group_name = azurerm_resource_group.example_rg.name
#   allocation_method   = var.Environment == "Test" ? "Static" : "Dynamic"
#   tags = {
#     environment = "Test"
#   }
# }
# # Create Network Interface
# resource "azurerm_network_interface" "example_nic" {
#   count = var.node_count
#   #name = "${var.resource_prefix}-NIC"
#   name                = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
#   location            = azurerm_resource_group.example_rg.location
#   resource_group_name = azurerm_resource_group.example_rg.name
#   #
#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.example_subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = element(azurerm_public_ip.example_public_ip.*.id, count.index)
#     #public_ip_address_id = azurerm_public_ip.example_public_ip.id
#     #public_ip_address_id = azurerm_public_ip.example_public_ip.id
#   }
# }
# # Creating resource NSG
# resource "azurerm_network_security_group" "example_nsg" {
#   name                = "${var.resource_prefix}-NSG"
#   location            = azurerm_resource_group.example_rg.location
#   resource_group_name = azurerm_resource_group.example_rg.name
#   # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
#   security_rule {
#     name                       = "Inbound"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   tags = {
#     environment = "Test"
#   }
# }
# # Subnet and NSG association
# resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
#   subnet_id                 = azurerm_subnet.example_subnet.id
#   network_security_group_id = azurerm_network_security_group.example_nsg.id
# }
# # Virtual Machine Creation — Linux
# resource "azurerm_virtual_machine" "example_linux_vm" {
#   count = var.node_count
#   name  = "${var.resource_prefix}-${format("%02d", count.index)}"
#   #name = "${var.resource_prefix}-VM"
#   location                      = azurerm_resource_group.example_rg.location
#   resource_group_name           = azurerm_resource_group.example_rg.name
#   network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
#   vm_size                       = "Standard_A1_v2"
#   delete_os_disk_on_termination = true
#   storage_image_reference {
#     publisher = "OpenLogic"
#     offer     = "CentOS"
#     sku       = "7.5"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "myosdisk-${count.index}"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "linuxhost"
#     admin_username = "terminator"
#     admin_password = "Password@1234"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = {
#     environment = "Test"
#   }
# }
