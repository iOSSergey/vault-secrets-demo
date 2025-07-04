# vault-secrets-demo

🔐 Demo repository for integrating HashiCorp Vault with AWS and Kubernetes to securely manage secrets.

## Contents
- `examples/aws` — Provision AWS IAM roles and policies for Vault.
- `examples/k8s` — Kubernetes manifests with Vault Agent injector.
- `scripts/cleanup.sh` — Clean up generated state files and resources.
- `.env` — Environment variables (not committed).

## Usage
1. **Fill in `.env` with your secrets and config:**
   ```plaintext
   AWS_REGION=us-east-1
   VAULT_ADDR=https://vault.example.com
   VAULT_TOKEN=s.xxxxx
   K8S_NAMESPACE=default
   ```

2. **Run Terraform for AWS:**
   ```bash
   cd examples/aws
   terraform init
   terraform apply
   ```

3. **Deploy Kubernetes resources:**
   ```bash
   kubectl apply -f examples/k8s/
   ```

4. **Cleanup resources:**
   ```bash
   ./scripts/cleanup.sh
   ```

---

## Examples

### 📄 `examples/aws/main.tf`
```hcl
provider "aws" {
  region = var.region
}

resource "aws_iam_policy" "vault_policy" {
  name        = "VaultDemoPolicy"
  description = "Policy for Vault secrets access"
  policy      = file("${path.module}/policy.json")
}
```

### 📄 `examples/aws/variables.tf`
```hcl
variable "region" {
  description = "AWS region"
  type        = string
}
```

### 📄 `examples/aws/outputs.tf`
```hcl
output "policy_arn" {
  value = aws_iam_policy.vault_policy.arn
}
```

### 📄 `examples/k8s/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "demo-role"
        vault.hashicorp.com/agent-inject-secret-config.txt: "secret/data/demo/config"
      labels:
        app: demo
    spec:
      serviceAccountName: vault-demo
      containers:
        - name: app
          image: nginx
```

### 📄 `examples/k8s/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-app
spec:
  selector:
    app: demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

### 📄 `examples/k8s/vault-agent-config.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-agent-config
data:
  config.hcl: |
    exit_after_auth = false
    pid_file = "/home/vault/pidfile"
    auto_auth {
      method "kubernetes" {
        mount_path = "auth/kubernetes"
        config = {
          role = "demo-role"
        }
      }
    }
    sink "file" {
      config = {
        path = "/home/vault/.vault-token"
      }
    }
```

### 📄 `scripts/cleanup.sh`
```bash
#!/bin/bash
echo "Cleaning up Terraform and Kubernetes resources..."
find . -name ".terraform" -type d -exec rm -rf {} +
find . -name "*.tfstate*" -delete
kubectl delete -f examples/k8s/ --ignore-not-found
```

---

## ✅ `.gitignore`
```plaintext
# Ignore Terraform state files and cache
.tfstate
.terraform/
.terraform.lock.hcl

# Ignore environment files
.env
```

Happy coding! 🚀
