# Release Strategy

## Goals
Release infrastructure and image changes safely, predictably, and with a clear rollback path.

## Release Principles
- Build immutable images whenever compute runtime dependencies change.
- Promote the same artifact through environments instead of rebuilding for every stage.
- Separate validation, approval, and apply steps.
- Roll out through smaller rings before broad production exposure.
- Treat observability and health checks as part of the release contract.

## Release Types
This repository supports several release classes:
- Infrastructure-only changes
- Image-based compute changes
- Shared platform changes
- Environment-specific configuration changes

Each class may use the same pipeline skeleton but should keep approval and blast-radius expectations explicit.

## Standard Promotion Flow
1. Build and validate the golden image or infrastructure change set.
2. Publish the approved image to Azure Compute Gallery when compute artifacts are involved.
3. Apply the change to the smallest safe non-production environment.
4. Verify plan output, health probes, logs, metrics, and key user journeys.
5. Promote the same artifact or same reviewed code revision to broader non-production targets.
6. Promote into production only after non-production validation is complete.

## Rollout Policy
- Start with the smallest safe environment, region, or ring.
- Use health probes, autoscale signals, alert thresholds, and dashboard checks as promotion gates.
- Pause promotion when error rate, latency, availability, or instance health regresses.
- Avoid combining unrelated high-risk changes in the same rollout window.

## Artifact Policy
- Reuse the same image artifact across environments whenever possible.
- Keep image version references explicit in stack inputs.
- Retain at least one previously known-good image version for rollback.
- Do not rely on mutable in-place package updates as the primary release path for compute nodes.

## Infrastructure Apply Policy
- Review plans before apply, especially replacements and destroys.
- Separate broad shared-service changes from narrow workload changes when practical.
- Apply production changes through approved workflows only.
- Record exceptions when emergency procedures bypass the standard release path.

## Rollback Policy
- Prefer switching back to the previous image version or stack input.
- Keep rollback steps simple enough to execute under incident pressure.
- Treat emergency config edits outside version control as temporary and reconcile them immediately after recovery.
- If a change cannot be rolled back safely, document the forward-fix strategy before release.

## Evidence Required for Promotion
Before promoting a release, confirm:
- Validation and formatting checks passed
- The reviewed plan matches the intended blast radius
- Health probes and dashboards are green
- Key logs and alerts show no new degradation
- Operators know the rollback path
