# Software Bill of Materials (SBOM)

## Project: sftp-container

| Property | Value |
|----------|-------|
| **Name** | sftp-container |
| **Version** | 1.0.0 |
| **Description** | Lightweight SFTP/SCP server based on Alpine Linux |
| **Generated** | 2026-02-25 |

---

## Components

### Base Image

| Package | Version | Purpose |
|---------|---------|---------|
| alpine | 3.19 | Lightweight Linux distribution |

### System Packages (Alpine apk)

| Package | Version | Purpose |
|---------|---------|---------|
| openssh-server | latest | SSH/SFTP server |
| shadow | latest | User management utilities |

### Source Files

| File | Type | Description |
|------|------|-------------|
| Dockerfile | Docker | Container build definition |
| docker-compose.yml | YAML | Docker Compose configuration |
| entrypoint.sh | Shell | Container entry point (generated) |

---

## Dependency Graph

```
sftp-container
└── alpine:3.19
    └── openssh-server
    └── shadow
```

---

## Security Notes

- Default credentials: `sftp:sftp` — change in production
- Consider using SSH keys instead of passwords
- Container runs as non-root user (UID/GID configurable)
- Exposes port 22 (SSH/SFTP)

---

## Build Information

```bash
# Build image
docker build -t sftp-container:latest .

# Image size (approx): 11.5 MB
```
