# Observability

## Scope
This document defines the baseline observability model for infrastructure and workload components managed by this repository.

## Goals
- Detect failures early
- Support rollout verification
- Shorten incident diagnosis time
- Make ownership and action paths clear

## Core Signals
- Metrics for health, latency, throughput, saturation, capacity, and autoscale behavior
- Logs for platform diagnostics, audit events, deployment activity, and workload output
- Traces for request-path visibility where supported by the workload and runtime

## Collection Model
- Enable diagnostic settings on supported Azure resources.
- Route logs and metrics to approved central sinks such as Log Analytics and managed monitoring services.
- Keep scrape agents, exporters, and forwarding configuration defined in code or image build artifacts.
- Avoid relying on manual portal configuration for observability-critical settings.

## Minimum Coverage by Domain

### Edge
- Access logs
- WAF events
- Probe health
- Backend availability
- TLS and certificate-related failures

### Compute
- Instance health
- CPU, memory, disk, and network utilization
- Boot diagnostics
- Extension failures
- Scale events and instance replacement activity

### Data
- Connection health
- Capacity and storage growth
- Backup status
- Replication status where applicable
- Throttling and service-level errors

### Security
- Sign-in events
- RBAC changes
- Secret and certificate access
- Policy violations and exemptions

## Alerting Principles
- Every alert should map to an owner and an expected action.
- Separate paging alerts from informational alerts.
- Prefer symptom-based alerts for urgent paging and cause-based alerts for diagnosis.
- Review noisy alerts after every incident and major release.

## Dashboard Expectations
- Keep environment dashboards structurally consistent across `dev`, `stg`, and `prod`.
- Show service health, release version, dependencies, and top recent alerts in one place.
- Include enough context to identify whether the issue is edge, compute, data, or platform-related.

## Release Verification
Observability is part of every rollout. Before promoting a change, confirm:
- Health probes are green
- Error rate and latency are within expected range
- Key logs show no systemic startup or dependency failures
- No new critical alerts were introduced by the change
