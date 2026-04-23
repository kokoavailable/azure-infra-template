# Runbook

## Purpose
This runbook captures the default operating procedures for validating, deploying, rolling back, and investigating infrastructure managed by this repository.

## Scope
Use this runbook when:
- Making a routine infrastructure change
- Promoting a new image or environment configuration
- Investigating a failed plan or apply
- Responding to incidents related to platform or workload infrastructure

## Prerequisites
- Azure access through approved identities and least-privilege roles
- Terraform (see root `.terraform-version`), Packer, pre-commit, and required CLIs installed for local operation
- Remote state backend bootstrapped before shared or workload stacks are applied
- Access to CI logs, plan artifacts, dashboards, and alert history

## Standard Change Flow
1. Create or update a feature branch.
2. Modify infrastructure code and the supporting documentation together.
3. Run local checks such as `make fmt`, `make validate`, and `make pre-commit`.
4. Open a pull request and inspect generated plans and workflow results.
5. Merge only after review and explicit approval.
6. Apply through the approved CI workflow for the target environment.
7. Confirm post-deploy health before considering the change complete.

## Local Validation Checklist
Before opening or updating a pull request, confirm:
- Formatting is clean
- Validation passes for affected stacks
- Documentation was updated when architecture or operations changed
- New inputs, outputs, or dependencies are described in the relevant README or doc
- Sensitive values are not committed to the repository

## Apply Procedure
When applying a change:
1. Confirm the target environment and region.
2. Review the plan for unexpected creates, destroys, or replacements.
3. Confirm prerequisites from earlier layers are already in place.
4. Apply using the approved workflow or operator path.
5. Verify health probes, dashboards, and alert state immediately after apply.

## Rollback Guidance
- Prefer rollback by reverting to the previous known-good image version or infrastructure input.
- Avoid emergency manual changes outside version control unless service restoration requires them.
- If an out-of-band change is made, reconcile it back into code as soon as the incident is stable.
- If rollback cannot be safely automated, document the manual procedure in the affected stack README.

## Incident Triage
When an issue occurs:
1. Determine whether the blast radius is limited to one stack, one region, or one environment.
2. Check the most recent apply, image promotion, DNS change, or secret rotation.
3. Review health probes, application logs, infrastructure diagnostics, and alert timelines.
4. Stabilize customer impact first.
5. Repair or revert the underlying infrastructure change only after the system is stable.

## Common Failure Categories
- Authentication or authorization failures in CI
- Provider initialization or backend state issues
- Dependency ordering problems between stacks
- Health probe or rollout failures after compute/image updates
- DNS or certificate misconfiguration at the edge

## Post-Incident Follow-Up
After recovery:
- Record timeline, trigger, mitigation, and user impact
- Capture whether rollback or forward-fix was used
- Update docs, alerts, or tests if the incident exposed a gap
- Create or update an ADR if the incident changes a long-term architecture decision

## Routine Operational Checks
- Review state drift and repeated plan noise
- Review image freshness and patch compliance
- Review alert noise and outdated dashboards
- Review unused resources, stale identities, and temporary exceptions
