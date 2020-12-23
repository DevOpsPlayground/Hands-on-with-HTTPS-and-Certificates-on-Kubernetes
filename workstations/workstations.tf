###############################################################################
# Configure isolated namespaces within the Kubernetes cluster for each attendee
###############################################################################
resource "random_pet" "pet" {
  count = var.num_attendees
}

resource "kubernetes_namespace" "ns" {
  for_each   = toset(random_pet.pet.*.id)

  metadata {
    name = each.key
  }
}

resource "kubernetes_service_account" "sa" {
  for_each   = toset(random_pet.pet.*.id)

  metadata {
    name      = "${each.key}-user"
    namespace = kubernetes_namespace.ns[each.key].metadata[0].name
  }
}

data "kubernetes_secret" "secret" {
  for_each   = toset(random_pet.pet.*.id)

  metadata {
    name      = kubernetes_service_account.sa[each.key].default_secret_name
    namespace = kubernetes_namespace.ns[each.key].metadata[0].name
  }
}

resource "kubernetes_role" "role" {
  for_each   = toset(random_pet.pet.*.id)

  metadata {
    name      = "${each.key}-role"
    namespace = kubernetes_namespace.ns[each.key].metadata[0].name
  }

  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["cert-manager.io"]
    resources  = ["issuers", "certificates"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "rb" {
  for_each   = toset(random_pet.pet.*.id)

  metadata {
    name      = "${each.key}-rb"
    namespace = kubernetes_namespace.ns[each.key].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.role[each.key].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sa[each.key].metadata[0].name
    namespace = kubernetes_namespace.ns[each.key].metadata[0].name
  }
}

####################################################################
# Create Azure virtual machines to act as workstations for attendees 
####################################################################
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public" {
  for_each   = toset(random_pet.pet.*.id)

  name                = "dpg-${each.key}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  depends_on = [random_pet.pet, azurerm_public_ip.public]
  for_each   = toset(random_pet.pet.*.id)

  name                = "dpg-${each.key}-ni"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public[each.key].id
  }
}

resource "azurerm_virtual_machine" "main" {
  for_each   = toset(random_pet.pet.*.id)

  name                  = "dpg-${each.key}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main[each.key].id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "dpg-${each.key}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = each.key
    admin_username = var.workstation_username
    admin_password = var.workstation_password
    custom_data = templatefile("${path.module}/templates/custom_data.sh.tpl",
      { 
        az_user     = azuread_service_principal.sp.application_id,
        az_password = var.app_password,
        az_tenant   = data.azurerm_client_config.current.tenant_id,
        linux_user  = var.workstation_username,
        host        = data.terraform_remote_state.aks-cluster.outputs.host,
        namespace   = kubernetes_namespace.ns[each.key].metadata[0].name,
        sa          = kubernetes_service_account.sa[each.key].metadata[0].name,
        ca_cert     = data.terraform_remote_state.aks-cluster.outputs.cluster_ca_certificate,
        token = data.kubernetes_secret.secret[each.key].data["token"] 
      }
    )
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.environment
  }
}