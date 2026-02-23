# OpenAEV on OCI — Standalone Terraform Module

Deploy [OpenAEV](https://filigran.io/solutions/openbas/) (Adversarial Exposure Validation) on an OCI Compute instance with Docker Compose.

## What Gets Deployed

- **OCI Compute VM (OpenAEV)** — Oracle Linux 8, VM.Standard.E4.Flex (4 OCPU, 32 GB RAM, 100 GB boot)
- **Docker Compose stack** with 10 services:
  - `pgsql` — PostgreSQL 17 (OpenAEV database)
  - `elasticsearch` — Elasticsearch 8.15.3
  - `rabbitmq` — RabbitMQ 4.0
  - `minio` — MinIO (S3-compatible object storage)
  - `openaev` — OpenAEV 2.1.8 (port 8080)
  - `collector-mitre-attack` — MITRE ATT&CK data collector
  - `collector-atomic-red-team` — Atomic Red Team collector
  - `injector-nmap` — Nmap scan injector
  - `injector-nuclei` — Nuclei vulnerability scanner injector
  - `injector-caldera` — MITRE Caldera integration injector

## Prerequisites

- Terraform >= 1.0
- OCI CLI configured (`~/.oci/config`)
- An OCI subnet (the attack subnet is recommended)
- SSH public key at `~/.ssh/id_rsa.pub`
- (Optional) A running Caldera server for injector/executor integration
- (Optional) OCI GOADv3 lab for network integration

## Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `tenancy_ocid` | Yes | — | OCI Tenancy OCID |
| `region` | No | `eu-frankfurt-1` | OCI region |
| `compartment_id` | Yes | — | Compartment for the VM |
| `subnet_id` | Yes | — | Subnet for the VM |
| `goad_subnet_id` | No | — | Subnet OCID of GOADv3 lab |
| `openaev_admin_token` | Yes | — | Admin API token |
| `caldera_url` | Yes | — | Caldera server URL |
| `caldera_api_key` | Yes | — | Caldera API key |

## Outputs

| Output | Description |
|--------|-------------|
| `instance_ocid` | Compute instance OCID |
| `private_ip` | VM private IP |
| `openaev_url` | OpenAEV web URL |
| `openaev_admin_token` | Admin token (for OCI-DEMO) |

## Network Integration

The module creates a Network Security Group (NSG) `nsg-security-tools` that:
1. Allows all traffic to/from OpenAEV.
2. Allows all traffic to/from the `goad_subnet_id` if provided.
3. Facilitates integration with Kali and Hexstrike instances (part of OCI-DEMO C7) via shared NSG or subnet rules.
4. Facilitates integration with OCI-DEMO control plane via resource tags.

## Post-Deploy

The VM cloud-init takes approximately 5-10 minutes to pull images and start all services. Check progress:

```bash
# SSH to the VM
ssh opc@<private_ip>

# Watch cloud-init
tail -f /var/log/cloud-init-output.log

# Check Docker containers
cd /opt/openaev && docker compose ps

# Verify OpenAEV API
curl http://localhost:8080/api/health
```

## Caldera Integration

OpenAEV connects to Caldera as both injector and executor. Ensure:
1. Caldera is reachable from the OpenAEV VM on the specified URL/port
2. The API key has red-team permissions
3. Network security lists allow traffic between the two VMs

## Destroy

```bash
terraform destroy
```
