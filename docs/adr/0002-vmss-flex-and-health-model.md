# ADR 0002: Use VMSS Flex with Explicit Health Model

- Status: Proposed
- Date: 2026-04-09

## Context
The workload compute tier requires controlled rolling updates, instance-level repair, and health-aware promotion. A compute platform that is easy to deploy is not sufficient if health semantics remain implicit or are defined too late in the process.

## Decision
Prefer Virtual Machine Scale Sets Flex for workload compute where its operational model matches the service needs, and define probe configuration, repair policy, and rollout health signals explicitly.

## Rationale
- VMSS Flex offers operational patterns that fit controlled instance rollout and replacement scenarios.
- Explicit health signals improve rollout safety and reduce ambiguity during incidents.
- Repair and promotion behavior should be designed up front rather than improvised after the first failure.

## Consequences
- Rollout behavior becomes more predictable.
- Health probes and instance-repair policy become mandatory design inputs.
- Some workloads may still require a different compute platform based on service characteristics.
