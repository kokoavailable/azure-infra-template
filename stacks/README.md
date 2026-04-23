# Stacks

Contains reusable scaffolding such as **`_stack-template`** for new Terraform stacks.

Platform and workload stacks under `platform/` and `spokes/` should start from `_stack-template` so tagging, backends, and provider defaults stay aligned with Stage 1 bootstrap (`platform/identity`, `platform/management`).
