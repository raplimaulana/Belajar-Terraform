terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=2.91.0" 
        }
    }
}

provider "azurerm" {
    feature {}
}

#Resource group
resource "azurerm_resource_group" "mtc-rg" {
    name     = "mtc-resources"
    location = "East Us"
    tags = {
        environment = "dev"
    }
}

#Virtual network
resource "azurerm_virtual_network" "mtc-vn" {
    name                = "mtc-network"
    resource_group_name = azurerm_resource_group.mtc-rg.name 
    location            = azurerm_resource_group.mtc-rg.location
    address_space       = ["10.123.0.0/16"] 

    tags = {
        environment = "dev"
    }
}

#Subnet 
resource "azurerm_subnet" "mtc-subnet" {
    name                 = "mtc-subnet"
    resource_group_name  = azurerm_resource_group.mtc-rg.name
    virtual_network_name = azurerm_virtual_network.mtc-vn.name 
    address_prefixes     = ["10.123.1.0/24"]

    tags = {
        environment = "dev"
    }
}

#Network security group
resource "azurerm_network_security_group" "mtc-sg" {
    name                = "mtc-sg"
    location            = azurerm_network_security_group.mtc-re.location
    resource_group_name = azurerm_network_security_group.mtc-rg.name

    tags = {
        environment = "dev"
    }
}

#Network security rule
resource "azurerm_network_security_rule" "mtc-dev-rule" {
    name        = "mtc-dev-rule"
    priority    = 100
    direction   = "Inbound"
    access      = "Allow"
    protocol    = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "123.123.123.123/32"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.mtc-rg.name 
    network_security_group_name = azurerm_resource_group.mtc-sg.name 
}

#Network security group association
resource "azurerm_subnet_network_security_group_association" "mtc-sga" {
    subnet_id                 = azurerm_subnet.mtc-subnet.subnet_id
    network_security_group_id = azurerm_network_security_group.mtc-sg.id 
}

#IP public 
resource "azure_public_ip" "mtc-ip" {
    name                = "mtc-ip"
    resource_group_name = azurerm_resource_group.mtc-rg.name
    location            = azurerm_network_security_group.mtc-rg.location
    allocation_method   = "Dynamic"                                                 #di azure, jika IP nya dibuat dynamic entah kenapa jadi tidak muncul nanti ip publicnya di terraform output  

    tags = {
        environment     = "dev"
    }
}

#Network interface 
resource "azurerm_network_interface" "mtc-nic" {
    name                = "mtc-nic"
    loation             = azurerm_resource_group.mtc-rg.location 
    resource_group_name = azurerm_resource_group.mtc-rg.name

    ip_configuration {
        name                         = "internal"
        subnet_id                    = azurerm_subnet.mtc-subnet.id 
        private_ip_adress_allocation = "Dynamic"
        public_ip_iddress_id         = azure_public_ip.mtc-ip.id
    }

    tags = {
        environmet = "dev"
    }
}

#VM
resource "azurerm_linux_virtual_machine" "mtc-vm" {
    name                  = "mtc-vm"
    resource_group_name   = azurerm_resource_group.mtc-rg.name 
    location              = azurerm_resource_group.mtc-rg.location
    size                  = "Standard_B1s"
    admin_username        = "adminuser"
    network_interface_ids = [azurerm_network_interface.mtc-nic.id]

    custom_data = filebase64("customdata.tpl")

    admin_ssh_key {
        username = "adminuser"
        public_key = fil("~/.ssh/mtcazurekey.pub")
    }

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

    #Provisioner
    provisioner "local-exec" {
        command = templatefile("${var.host_os}-ssh-scrip.tpl", {
            hostname     = self.public_ip_adress,
            user         = "adminuser",
            identifyfile = "~/.ssh/mtcazurekey" 
        })
        interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
    }

    tags = {
        environment = "dev"
    }
}

#Datasource
data "azurerm_public_ip" "mtc-ip-data" {
    name                = azure_public_ip.mtc-ip.name
    resource_group_name = azurerm_resource_group.mtc-rg.name
}

#Output
output "public_ip_address" {
    value = "${azurerm_linux_virtual_machine.mtc-vm.name}: ${data.azure_public_ip.mtc-ip-data.ip_address}"
}