# Kubernetes Secrets Guide

## Creating Secrets with kubectl

Use `kubectl create secret generic` with `--from-literal` to avoid manual base64 encoding:

```bash
kubectl create secret generic sftp-secret \
  --from-literal=username=admin \
  --from-literal=password=sftppassword \
  -n sftp
```

## Manual Base64 Encoding (if using kubectl edit)

When editing secrets manually, values must be base64 encoded:

```bash
# Encode a value
echo -n "your-password" | base64
# Output: eW91ci1wYXNzd29yZA==

# Decode to verify
echo -n "eW91ci1wYXNzd29yZA==" | base64 -d
# Output: your-password
```

### Example Secret Format

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sftp-secret
  namespace: sftp
data:
  username: YWRtaW4=        # "admin" base64
  password: c2Z0cHBhc3N3b3Jk  # "sftppassword" base64
```
