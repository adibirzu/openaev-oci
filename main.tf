terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }
  }
}

# ─── Data Sources ───

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ol8" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_core_subnet" "openaev" {
  subnet_id = var.subnet_id
}

# ─── Network Security ───

resource "oci_core_network_security_group" "security_tools" {
  compartment_id = var.compartment_id
  vcn_id         = data.oci_core_subnet.openaev.vcn_id
  display_name   = "nsg-security-tools"
}

# Rule for internal traffic between security tools
resource "oci_core_network_security_group_security_rule" "internal_ingress" {
  network_security_group_id = oci_core_network_security_group.security_tools.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.security_tools.id
}

# Rule for GOADv3 integration (allow all traffic from/to GOAD subnet if specified)
resource "oci_core_network_security_group_security_rule" "goad_ingress" {
  count                     = var.goad_subnet_id != "" ? 1 : 0
  network_security_group_id = oci_core_network_security_group.security_tools.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source_type               = "CIDR_BLOCK"
  source                    = data.oci_core_subnet.goad[0].cidr_block
}

data "oci_core_subnet" "goad" {
  count     = var.goad_subnet_id != "" ? 1 : 0
  subnet_id = var.goad_subnet_id
}

# ─── Compute Instance: OpenAEV ───

resource "oci_core_instance" "openaev" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = var.display_name
  shape               = var.shape
  freeform_tags       = { "OCI-DEMO" : "openaev-platform" }

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ol8.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.security_tools.id]
  }

  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data           = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {
      openaev_admin_email    = var.openaev_admin_email
      openaev_admin_password = var.openaev_admin_password
      openaev_admin_token    = var.openaev_admin_token
      caldera_url            = var.caldera_url
      caldera_api_key        = var.caldera_api_key
      pg_password            = random_password.pg.result
      es_password            = random_password.es.result
      rabbitmq_password      = random_password.rabbitmq.result
      minio_password         = random_password.minio.result
    }))
  }
}

# ─── Generated Credentials ───

resource "random_password" "pg" {
  length  = 32
  special = false
}

resource "random_password" "es" {
  length  = 32
  special = false
}

resource "random_password" "rabbitmq" {
  length  = 32
  special = false
}

resource "random_password" "minio" {
  length  = 32
  special = false
}

# ─── VNIC Data ───

data "oci_core_vnic_attachments" "openaev" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.openaev.id
}

data "oci_core_vnic" "openaev" {
  vnic_id = data.oci_core_vnic_attachments.openaev.vnic_attachments[0].vnic_id
}
