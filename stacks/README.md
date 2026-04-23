# Stacks

Holds **`_stack-template`**: a minimal Terraform scaffold for **new** stacks (remote `azurerm` backend, provider defaults, `terraform validate` placeholder).

- **New workload stacks** under `spokes/`: copy `_stack-template`, then replace the placeholder in `main.tf` and keep/adjust `locals` (e.g. `common_tags`) per `docs/naming-conventions.md`.
- **New platform stacks** under `platform/`: either start from `_stack-template` and **drop** workload-oriented variables/tags you do not need, or copy the structure from an existing platform stack (e.g. `platform/identity/02-identity-federation`, `platform/management/03-policy-governance`) so inputs match that layer.

In all cases, align **backend**, **provider**, and **versions** with Stage 1 bootstrap (`scripts/bootstrap`, `platform/identity`, `platform/management`).
