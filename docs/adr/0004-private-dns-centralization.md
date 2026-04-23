# ADR 0004: Centralize Private DNS Ownership

- Status: Accepted
- Date: 2026-04-09

## Context
Private endpoint-heavy environments can drift quickly when each workload manages duplicate private DNS zones independently. Duplicate zones make onboarding harder, create inconsistent resolution behavior, and complicate incident response.

## Decision
Manage shared private DNS zones centrally and link approved workload VNets to those zones.

## Rationale
- Central ownership reduces duplicate zones and conflicting records.
- Shared managed-service namespaces should behave consistently across workloads.
- Resolver and forwarding dependencies are easier to document and operate when ownership is clear.

## Consequences
- Duplicate zones and conflicting records are reduced.
- Central ownership must provide clear onboarding and change procedures.
- VNet links, forwarding paths, and exceptions must be documented carefully.
