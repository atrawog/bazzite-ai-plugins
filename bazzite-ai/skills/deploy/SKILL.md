---
name: deploy
description: |
  Helm-based application deployment to k3d Kubernetes clusters. Supports JupyterHub
  multi-user notebook server and KubeAI GPU-accelerated LLM inference. Automatically
  creates k3d cluster if needed, manages configuration, and provides lifecycle commands.
  Use when users need to run multi-user Jupyter notebooks or AI inference workloads.
---

# deploy - Kubernetes Application Deployment

## Overview

The `deploy` command manages Helm-based application deployments to k3d Kubernetes clusters. It handles the full lifecycle: configuration, installation, upgrades, and uninstallation.

**Supported Applications:**
- **JupyterHub** - Multi-user notebook server
- **KubeAI** - GPU-accelerated LLM inference server (OpenAI-compatible API)

**Key Concept:** Deploy commands use k3d clusters (lightweight k3s in Podman). If a cluster doesn't exist, it's automatically created.

## Quick Reference

### JupyterHub

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust deploy jupyterhub config [--instance=N]` | Configure deployment (creates k3d if needed) |
| Install | `ujust deploy jupyterhub install [--instance=N]` | Deploy JupyterHub to k3d |
| Upgrade | `ujust deploy jupyterhub upgrade [--instance=N]` | Upgrade Helm release |
| Status | `ujust deploy jupyterhub status [--instance=N]` | Show deployment status |
| Uninstall | `ujust deploy jupyterhub uninstall [--instance=N]` | Remove deployment (keep config) |
| Delete | `ujust deploy jupyterhub delete [--instance=N]` | Remove config and deployment |

### KubeAI

| Action | Command | Description |
|--------|---------|-------------|
| Config | `ujust deploy kubeai config [--instance=N]` | Configure KubeAI deployment |
| Install | `ujust deploy kubeai install [--instance=N]` | Deploy KubeAI to k3d cluster |
| Upgrade | `ujust deploy kubeai upgrade [--instance=N]` | Upgrade Helm release |
| Status | `ujust deploy kubeai status [--instance=N]` | Show KubeAI deployment status |
| Model | `ujust deploy kubeai model --model=NAME` | Deploy a model to KubeAI |
| Uninstall | `ujust deploy kubeai uninstall [--instance=N]` | Remove KubeAI deployment |
| Delete | `ujust deploy kubeai delete [--instance=N]` | Remove config and deployment |

## Prerequisites

```bash
# Helm must be installed (not included in base bazzite-ai)
ujust install helm

# k3d is built into bazzite-ai (no action needed)
```

## Parameters

| Parameter | Long Flag | Short | Default | Description |
|-----------|-----------|-------|---------|-------------|
| app | (positional) | - | required | Application name (jupyterhub) |
| action | (positional) | - | required | Action: config, install, etc. |
| instance | `--instance` | `-n` | `1` | k3d cluster instance number |
| namespace | `--namespace` | - | `jupyterhub` | Kubernetes namespace |
| chart_version | `--chart-version` | `-v` | (latest) | Helm chart version |
| admin_user | `--admin-user` | `-u` | `admin` | Admin username |
| storage_size | `--storage-size` | - | `10Gi` | User storage size |
| cpu_limit | `--cpu-limit` | - | `2` | User CPU limit |
| memory_limit | `--memory-limit` | - | `4Gi` | User memory limit |

## JupyterHub Deployment

### Configuration

```bash
# Default: Configure with all defaults (creates k3d cluster if needed)
ujust deploy jupyterhub config

# Specific k3d instance (long form)
ujust deploy jupyterhub config --instance=2

# Specific k3d instance (short form)
ujust deploy jupyterhub config -n 2

# Custom admin username
ujust deploy jupyterhub config --admin-user=myuser

# Custom resource limits
ujust deploy jupyterhub config --cpu-limit=4 --memory-limit=8Gi
```

**Configuration Files:**

```
~/.config/deploy/jupyterhub/{INSTANCE}/
  config.env      # Deployment settings
  values.yaml     # Generated Helm values
```

### Installation

```bash
# Install JupyterHub (uses config from config action)
ujust deploy jupyterhub install

# Install to specific instance
ujust deploy jupyterhub install --instance=2
ujust deploy jupyterhub install -n 2
```

**What Happens:**
1. Verifies Helm is installed
2. Ensures k3d cluster exists and is running
3. Adds JupyterHub Helm repository
4. Installs/upgrades via Helm with generated values
5. Waits for deployment to be ready

### Access

After installation:

```bash
# Via Traefik ingress (default for instance 1)
http://jupyterhub.localhost:8080

# Via kubectl port-forward
ujust k3d shell -- kubectl -n jupyterhub port-forward svc/proxy-public 8888:80
# Then access: http://localhost:8888

# Default login (dummy authenticator)
Username: admin (or any username)
Password: changeme (or any password)
```

**Port Calculation by Instance:**

| Instance | HTTP Port | HTTPS Port |
|----------|-----------|------------|
| 1 | 8080 | 8443 |
| 2 | 8081 | 8444 |
| N | 8079+N | 8442+N |

### Status Check

```bash
# Check deployment status
ujust deploy jupyterhub status

# Specific instance
ujust deploy jupyterhub status --instance=2
```

Shows:
- Configuration details
- k3d cluster status
- Helm release info
- Pod status
- Access URLs

### Upgrade

```bash
# Upgrade to latest chart version
ujust deploy jupyterhub upgrade

# Specific instance
ujust deploy jupyterhub upgrade -n 2
```

### Uninstall

```bash
# Uninstall deployment (keep config files)
ujust deploy jupyterhub uninstall

# Specific instance
ujust deploy jupyterhub uninstall -n 2
```

### Delete

```bash
# Delete deployment AND config files
ujust deploy jupyterhub delete

# Specific instance
ujust deploy jupyterhub delete -n 2
```

## Architecture

### k3d Cluster Integration

JupyterHub is deployed to k3d clusters (`bazzite-{INSTANCE}`):

- **Traefik Ingress:** Built-in, handles HTTP/HTTPS routing
- **Local Path Provisioner:** Provides persistent storage
- **bazzite-ai Network:** JupyterHub pods can access other services (ollama, etc.)

### Network Connectivity

From JupyterHub notebooks to bazzite-ai services:

```python
# In a Jupyter notebook
import requests
response = requests.get("http://ollama:11434/api/tags")
print(response.json())
```

### Storage

- **Hub Database:** SQLite on PVC (local-path)
- **User Volumes:** Dynamic PVCs on local-path storage class

## Testing

```bash
# Full lifecycle test (uses instance 90)
ujust test deploy all

# Individual test steps
ujust test deploy config --instance=90
ujust test deploy install --instance=90
ujust test deploy status --instance=90
ujust test deploy uninstall --instance=90
ujust test deploy delete --instance=90
```

## Troubleshooting

### Helm Not Found

```bash
# Install Helm first
ujust install helm
```

### k3d Cluster Issues

```bash
# Check cluster status
ujust k3d status --instance=1

# Start if stopped
ujust k3d start --instance=1

# Recreate if corrupted
ujust k3d delete --instance=1
ujust deploy jupyterhub config --instance=1
```

### Pods Not Starting

```bash
# Check pod status
ujust k3d shell -- kubectl get pods -n jupyterhub

# Check pod events
ujust k3d shell -- kubectl describe pods -n jupyterhub

# Check logs
ujust k3d shell -- kubectl logs -n jupyterhub -l component=hub
```

### Ingress Not Working

```bash
# Check Traefik status
ujust k3d shell -- kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Check ingress
ujust k3d shell -- kubectl get ingress -n jupyterhub

# Test direct access via port-forward
ujust k3d shell -- kubectl -n jupyterhub port-forward svc/proxy-public 8888:80
```

## Future Applications

The deploy framework is designed to support additional Helm charts:

- ArgoCD (GitOps)
- Prometheus (Monitoring)
- Grafana (Dashboards)
- cert-manager (TLS)
