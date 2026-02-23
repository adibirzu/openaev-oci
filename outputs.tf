output "instance_ocid" {
  description = "OCID of the OpenAEV compute instance"
  value       = oci_core_instance.openaev.id
}

output "private_ip" {
  description = "Private IP of the OpenAEV VM"
  value       = data.oci_core_vnic.openaev.private_ip_address
}

output "public_ip" {
  description = "Public IP of the OpenAEV VM (if assigned)"
  value       = data.oci_core_vnic.openaev.public_ip_address
}

output "openaev_url" {
  description = "OpenAEV web URL"
  value       = "http://${data.oci_core_vnic.openaev.private_ip_address}:8080"
}

output "openaev_admin_token" {
  description = "OpenAEV admin API token for OCI-DEMO integration"
  value       = var.openaev_admin_token
  sensitive   = true
}
