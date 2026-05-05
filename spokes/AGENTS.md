# spokes/AGENTS.md

## Scope

This directory contains workload-specific spoke environments.

## Rules

Start with `dev`.

Do not modify `prod` unless explicitly requested.

One PR should usually affect one spoke stack.

Preferred implementation order:

1. `00-spoke-network`
2. `05-secrets`
3. `06-configuration`
4. `20-data`
5. `30-compute`
6. `10-edge`
7. `40-observability`

Cross-stack dependencies must flow downstream only.

Do not introduce cyclic remote-state dependencies.

Do not run apply or destroy.