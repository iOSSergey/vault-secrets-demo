provider "aws" {
  region = var.region
}

resource "aws_iam_policy" "vault_policy" {
  name        = "VaultDemoPolicy"
  description = "Policy for Vault secrets access"
  policy      = file("${path.module}/policy.json")
}
