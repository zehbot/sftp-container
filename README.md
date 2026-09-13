# SFTP Container

Lightweight SFTP/SCP server running in Docker. Based on Alpine Linux.

## Quick Start

A prebuilt multi-arch image is published as
`inkassodeppen/sftpcontainer:latest` (`docker run -d -p 2222:22 -e SFTP_USER=myuser -e SFTP_PASS=mypassword inkassodeppen/sftpcontainer:latest`).
To build it yourself:

```bash
# Build
docker build -t sftp-container:latest .

# Run with docker run
docker run -d \
  -p 2222:22 \
  -e SFTP_USER=myuser \
  -e SFTP_PASS=mypassword \
  sftp-container:latest

# Or with docker-compose
docker-compose up -d
```

## Permission Issues

If you get a permission error like:
```
permission denied while trying to connect to the Docker daemon socket
```

Use `sg docker -c` to run docker commands with docker group permissions:

```bash
# Build
sg docker -c "docker build -t sftp-container:latest ."

# Run container
sg docker -c "docker run -d -p 2222:22 -e SFTP_USER=myuser -e SFTP_PASS=mypassword sftp-container:latest"

# List containers
sg docker -c "docker ps"

# View logs
sg docker -c "docker logs container_id"

# docker-compose
sg docker -c "docker-compose up -d"
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SFTP_USER` | `sftp` | SFTP username |
| `SFTP_PASS` | `sftp` | SFTP password |
| `SFTP_UID` | `1000` | UID for the user |
| `SFTP_GID` | `1000` | GID for the user |
| `SFTP_ROOT` | `/home/sftp` | Root directory for SFTP |

## Usage

**Connect via SFTP:**
```bash
sftp -P 2222 sftp@localhost
# password: sftp
```

**Connect via SCP:**
```bash
scp -P 2222 file.txt sftp@localhost:/upload/
```

**With docker-compose:**
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f
```

## Volume Mounts

```bash
docker run -d \
  -p 2222:22 \
  -v /path/to/data:/home/sftp \
  -e SFTP_USER=myuser \
  -e SFTP_PASS=mypassword \
  sftp-container:latest
```

## Security Notes

- Change default credentials in production
- Consider using SSH keys instead of passwords
- `sshd` runs as root inside the container (it must bind port 22 and change
  users); the SFTP login itself is the non-root user created at startup

## K3s Deployment

Two manifests are included, both with Longhorn storage:

| File | Authentication |
|------|----------------|
| `sftp-k3s-manifest.yaml` | password (`SFTP_PASS`) |
| `sftp-keybased-k3s-manifest.yaml` | SSH key (`SSH_KEY`, mounted from the Secret with `defaultMode: 0600`) |

### Resources Created

| Resource | Description |
|----------|-------------|
| Secret `sftp-secret` | SFTP credentials (password and/or SSH key) |
| PersistentVolumeClaim `sftp-data-pvc` | Longhorn PVC (1Gi) |
| Deployment `sftp-deployment` | sftp-container pods, image `inkassodeppen/sftpcontainer:latest` |
| Service `sftp-service-nodeport` | NodePort 30022 |
| Service `sftp-service-loadbalancer` | LoadBalancer, port 22 |

### Usage

```bash
# Create namespace and apply one of the manifests
kubectl create namespace sftp
kubectl apply -f sftp-k3s-manifest.yaml            # password auth
# kubectl apply -f sftp-keybased-k3s-manifest.yaml # key auth

# Check status
kubectl get all -n sftp

# View logs
kubectl logs -n sftp -l app=sftp

# Connect via SFTP
sftp -P 30022 sftp@<k3s-node-ip>
```

The manifests use the published image, so nodes need access to `registry-1.docker.io`.
To use a locally built image instead, change the `image:` field and keep
`imagePullPolicy` in step.

See also `howto-secrets.md` and `howto-sftp-key-based-auth.md`.

### Customization

- **Change storage:** Edit `storageClassName` in the PVC (e.g., `local-path`)
- **Change credentials:** Update the Secret or use `kubectl edit secret sftp-secret -n sftp`
- **Change port:** Edit `nodePort` in the Service (default: `30022`)
