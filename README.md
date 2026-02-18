# OpenAEV on OCI — Standalone Terraform Module

Deploy [OpenAEV](https://filigran.io/solutions/openbas/) (Adversarial Exposure Validation) on an OCI Compute instance with Docker Compose.

## What Gets Deployed

- **OCI Compute VM** — Oracle Linux 8, VM.Standard.E4.Flex (4 OCPU, 32 GB RAM, 100 GB boot)
- **Docker Compose stack** with 9 services:
  - `pgsql` — PostgreSQL 17 (OpenAEV database)
  - `elasticsearch` — Elasticsearch 8.15.3 (single-node, 1 GB heap)
  - `rabbitmq` — RabbitMQ 4.0 with management UI
  - `minio` — MinIO (S3-compatible object storage)
  - `openaev` — OpenAEV 2.1.8 (port 8080)
  - `collector-mitre-attack` — MITRE ATT&CK data collector
  - `collector-atomic-red-team` — Atomic Red Team collector
  - `injector-nmap` — Nmap scan injector
  - `injector-nuclei` — Nuclei vulnerability scanner injector

## Prerequisites

- Terraform >= 1.0
- OCI CLI configured (`~/.oci/config`)
- An OCI subnet (the attack subnet is recommended)
- SSH public key at `~/.ssh/id_rsa.pub` (or override `ssh_public_key_path`)
- (Optional) A running Caldera server for injector/executor integration

## Quick Start

```bash
cd external/openaev

# Copy and fill in required variables
cp .env.example .env
# Edit .env with your OCI OCIDs and credentials
source .env

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
| `shape` | No | `VM.Standard.E4.Flex` | VM shape |
| `ocpus` | No | `4` | OCPUs |
| `memory_in_gbs` | No | `32` | Memory in GB |
| `boot_volume_size_in_gbs` | No | `100` | Boot volume in GB |
| `ssh_public_key_path` | No | `~/.ssh/id_rsa.pub` | SSH public key path |
| `display_name` | No | `oci-demo-openaev` | VM display name |
| `openaev_admin_email` | No | `admin@openaev.local` | Admin email |
| `openaev_admin_password` | Yes | — | Admin password |
| `openaev_admin_token` | Yes | — | Admin API token |
| `caldera_url` | Yes | — | Caldera server URL |
| `caldera_api_key` | Yes | — | Caldera API key |

## Outputs

| Output | Description |
|--------|-------------|
| `instance_ocid` | Compute instance OCID |
| `private_ip` | VM private IP |
| `public_ip` | VM public IP (if assigned) |
| `openaev_url` | OpenAEV web URL |

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
