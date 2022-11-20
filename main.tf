/*
{
  "appId": "9a581dd0-731a-4918-94a0-e50155a389e5",
  "displayName": "azure-cli-2022-11-05-02-53-14",
  "password": "pCO8Q~cFGKpBsucMK~aajDLdrKN0gxpPwU3DCb8~",
  "tenant": "cea297cb-9bde-428d-9a6e-48fa9c582ed6"
}
*/
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.29.1" #=3.29.1, ">=3.0.0,<=3.1.0", ~2.0
    }
  }
  required_version = ">=1.1.0" #locking terraform version
}

provider "azurerm" {
  # Configuration options
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  alias           = "dev-team"
  subscription_id = "6b79625d-9012-449c-b62d-bad954e598f0"     #subscription ID
  client_id       = "180ed599-fedf-4bbe-8ecd-8709f53f3412"     #appid
  client_secret   = "won8Q~lEItDNuplQd-BHztFCmPzj7wsKd400qaZT" #password
  tenant_id       = "cea297cb-9bde-428d-9a6e-48fa9c582ed6"     #tenantID
}
resource "azurerm_public_ip" "example" {
  provider            = azurerm.dev-team
  name                = "test-publicip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"

}
resource "azurerm_resource_group" "example" {
  provider = azurerm.dev-team #referencing a subscription (meta argument)
  name     = "test-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "example" {
  provider            = azurerm.dev-team
  name                = "test-network"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name #cross referencing attribute
}

resource "azurerm_subnet" "example" {
  provider             = azurerm.dev-team
  name                 = "test-internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "example" {
  provider            = azurerm.dev-team
  name                = "test-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    primary                       = true
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  provider                        = azurerm.dev-team
  name                            = "test-machine"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = "Standard_DS2_v2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  provisioner "local-exec" {
    when       = create   #creation provisioner
    on_failure = continue #prevents tainting of resource
    command    = "echo ${azurerm_linux_virtual_machine.example.name} > vmname.txt"
  }
  provisioner "file" { #file is copied to remote resource
    source      = "D:\\terraform projects\\terraform-tf\\test.sh" #change this path
    destination = "/tmp/test.sh"
  }
  provisioner "remote-exec" {
    when       = create
    on_failure = continue
    inline = [
      "chmod +x /tmp/test.sh",
      "/tmp/test.sh",
      "rm /tmp/test.sh"
    ]
  }
  connection {
    type     = "ssh"
    user     = self.admin_username
    password = self.admin_password
    host     = self.public_ip_address
  }
}