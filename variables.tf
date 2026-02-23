# ─── OCI Provider ───
variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "region" {
  description = "OCI Region (e.g., eu-frankfurt-1)"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "compartment_id" {
  description = "Compartment OCID for the OpenAEV VM"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID for the OpenAEV VM (attack subnet recommended)"
  type        = string
}

# ─── Compute ───
variable "shape" {
  description = "VM shape"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus" {
  description = "Number of OCPUs"
  type        = number
  default     = 4
}

variable "memory_in_gbs" {
  description = "Memory in GBs"
  type        = number
  default     = 32
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GBs"
  type        = number
  default     = 100
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "display_name" {
  description = "Display name for the VM"
  type        = string
  default     = "oci-demo-openaev"
}

# ─── OpenAEV ───
variable "openaev_admin_email" {
  description = "OpenAEV admin email"
  type        = string
  default     = "admin@openaev.local"
}

variable "openaev_admin_password" {
  description = "OpenAEV admin password"
  type        = string
  sensitive   = true
}

variable "openaev_admin_token" {
  description = "OpenAEV admin API token"
  type        = string
  sensitive   = true
}

# ─── Caldera Integration ───
variable "caldera_url" {
  description = "Caldera server URL (e.g., http://10.100.2.20:8888)"
  type        = string
}

variable "caldera_api_key" {
  description = "Caldera red-team API key"
  type        = string
  sensitive   = true
}

# ─── Network Integration (GOADv3) ───
variable "goad_subnet_id" {
  description = "Subnet OCID for the GOADv3 lab for network integration"
  type        = string
  default     = ""
}
