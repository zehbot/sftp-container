# SFTP Key-Based Authentication Guide

## Overview

This SFTP container supports both password and SSH key-based authentication. Keys are managed via:
- **Docker**: Environment variable `SSH_KEY`
- **Kubernetes**: Secret with `authorized_keys` field

---

## Docker Compose (Local)

### Option 1: Via Environment Variable

```yaml
services:
  sftp:
    environment:
      - SFTP_USER=sftp
      - SFTP_PASS=sftp          # Keep for password fallback
      - SSH_KEY=ssh-rsa AAAA... # Your public key
```

### Option 2: Via Volume Mount (Recommended)

Create authorized_keys file on host:

```bash
mkdir -p /mnt/sftp/.ssh
touch /mnt/sftp/.ssh/authorized_keys
chmod 600 /mnt/sftp/.ssh/authorized_keys
chmod 755 /mnt/sftp/.ssh

# Add your public key(s)
echo "ssh-rsa AAAA... user@host" > /mnt/sftp/.ssh/authorized_keys
```

Docker-compose.yml:

```yaml
volumes:
  - /mnt/sftpdata:/home/sftp
  - /mnt/sftp/.ssh/authorized_keys:/home/sftp/.ssh/authorized_keys:ro
```

---

## Kubernetes (K3s)

### Secret Definition

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sftp-secret
  namespace: sftp
type: Opaque
stringData:
  SFTP_USER: sftp
  SFTP_PASS: sftp
  authorized_keys: |
    ssh-rsa AAAAB3... key1@host
    ssh-ed25519 BBBBB... key2@host
    # Add more keys as needed
```

### Deployment Volume Mount

```yaml
volumeMounts:
  - name: ssh-keys
    mountPath: /home/sftp/.ssh
    readOnly: true
volumes:
  - name: ssh-keys
    secret:
      secretName: sftp-secret
      items:
        - key: authorized_keys
          path: authorized_keys
      defaultMode: 0600
```

---

## Adding Multiple Keys

For multiple users or machines, add each public key on a new line in `authorized_keys`:

```
ssh-rsa AAAAB3... user@machine1
ssh-ed25519 CCCCC... user@machine2
ssh-rsa DDDDD... user@machine3
```

---

## Generating SSH Keys

### ED25519 (Recommended)

```bash
ssh-keygen -t ed25519 -C "sftp-user"
```

### RSA

```bash
ssh-keygen -t rsa -b 4096 -C "sftp-user"
```

**Files generated:**
- `id_ed25519` (or `id_rsa`) - **Private key** (keep secret!)
- `id_ed25519.pub` (or `id_rsa.pub`) - **Public key** (add to authorized_keys)

---

## Connecting

```bash
# Using private key
sftp -i /path/to/private_key -P 2222 sftp@localhost

# With password
sftp -P 2222 sftp@localhost
```

---

## Security Notes

- Private key permissions: `chmod 600 ~/.ssh/id_*`
- Authorized keys file: `chmod 600 authorized_keys`
- `.ssh` directory: `chmod 700 .ssh`
- Keep `SFTP_PASS` empty for key-only authentication
