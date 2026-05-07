# Workload spokes

Environment-scoped workload boundaries under `spokes/<env>/<spoke-name>/kr/koreacentral/`.

Environments: **dev**, **stg**, **prod**. Spoke examples: **app-main**, **shared-airflow**, **shared-observability**.

Conventions: `docs/stack-conventions.md` and `docs/architecture.md` (Stage 0 decisions).

Utility access and runtime compute are separate concerns. Dev may include a restricted public utility VM for operator workflows, but application runtime belongs in the compute layer and staging/production utility access should use private administration paths.
