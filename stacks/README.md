# Environment Stacks

Environment-scoped deployed stack instances live under
`stacks/<env>/kr/koreacentral/`.

Each environment owns its own hub-and-spoke boundary:

- `hub/` for the environment-owned regional hub network, private DNS posture,
  egress routing/security, and shared operations access.
- `spokes/<spoke-name>/` for workload-specific stacks such as `app-main`,
  `shared-airflow`, and `shared-observability`.

Environments: **dev**, **stg**, **prod**.

Conventions: `docs/stack-conventions.md` and `docs/architecture.md` (Stage 0 decisions).

Reusable scaffolds live under `templates/`.

Utility access and runtime compute are separate concerns. Dev may include a
restricted public utility VM for operator workflows, but application runtime
belongs in the compute layer and staging/production utility access should use
private administration paths.
