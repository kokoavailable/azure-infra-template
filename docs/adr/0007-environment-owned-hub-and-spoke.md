# ADR 0007: Use Environment-Owned Hub-and-Spoke Boundaries

- Status: Accepted
- Date: 2026-05-10

## Context

The repository originally modeled Korea Central connectivity as one shared
platform hub under `platform/connectivity/kr/koreacentral/hub/`, with workload
spokes under `spokes/<env>/<spoke-name>/kr/koreacentral/`.

That model keeps regional connectivity centralized, but it also means a hub
network, private DNS posture, egress routing, firewall placement, and shared
operations access can affect multiple execution environments. For this
repository, the preferred operating model is stronger execution-environment
separation: development, staging, and production should have independently
owned hub-and-spoke boundaries unless a later ADR explicitly accepts shared
connectivity.

## Decision

Move from a single platform-owned regional hub to environment-owned regional
hub-and-spoke layouts under `stacks/`.

The canonical layout is:

```text
stacks/
  dev/
    kr/koreacentral/
      hub/
        00-hub-network/
        05-private-dns/
        10-egress-routing-security/
        20-access-ops/
      spokes/
        app-main/
          00-spoke-network/
          05-secrets/
          06-configuration/
          20-data/
          25-utility-access/
          30-compute/
          10-edge/
          40-observability/
  stg/
    kr/koreacentral/
      hub/
      spokes/
  prod/
    kr/koreacentral/
      hub/
      spokes/
```

`platform/` remains for organization-level or globally shared capabilities such
as identity federation, policy governance, public DNS, artifact registries, and
other explicitly accepted shared services.

The former reusable-template role of top-level `stacks/` moves to `templates/`.
`templates/` contains generic scaffolds such as `_stack-template`; `stacks/`
contains deployed stack instances.

## Rationale

- Environment-owned hubs reduce the blast radius of routing, firewall, private
  DNS, and operations-access changes.
- Production networking can have stricter review and approval requirements
  without coupling those decisions to development iteration.
- Development can remain cheaper or simpler without becoming an implicit
  dependency for staging or production.
- Hub and spoke ownership becomes explicit inside each environment boundary.
- The layout makes the dependency direction easier to review:
  environment hub stacks publish outputs consumed by environment spoke stacks.

## Consequences

- Some infrastructure is duplicated across `dev`, `stg`, and `prod`.
- CIDR/IPAM planning must reserve non-overlapping ranges for each environment's
  hub and spokes.
- Private DNS centralization remains valid, but ownership moves from one shared
  platform hub to each environment hub unless a specific shared zone is approved.
- Existing references to `platform/connectivity/kr/koreacentral/hub/`,
  `spokes/<env>/...`, and reusable `stacks/_stack-template` must be migrated to
  the new `stacks/<env>/...` and `templates/_stack-template` layout.
- Apply order changes from platform hub before all spokes to per-environment
  hub before that environment's spokes.
- Cross-environment dependencies remain discouraged and must be documented when
  unavoidable.

## Dependency Rule

Allowed direction:

```text
platform/global-or-org-shared
  -> stacks/<env>/kr/koreacentral/hub
  -> stacks/<env>/kr/koreacentral/spokes/<spoke-name>
```

Disallowed direction:

```text
stacks/prod -> stacks/dev
stacks/dev -> stacks/prod
platform/* -> stacks/* state
hub stack -> spoke stack in the same environment
```

Hub stacks must not read spoke state. Spoke stacks may consume stable outputs
from the hub in the same environment.

## Migration Plan

1. Update repository documentation and scoped `AGENTS.md` files to describe
   `stacks/<env>/kr/koreacentral/{hub,spokes}` as the canonical layout.
2. Move reusable stack templates from `stacks/` to `templates/`.
3. Move the existing hub scaffold from
   `platform/connectivity/kr/koreacentral/hub/` to
   `stacks/dev/kr/koreacentral/hub/`.
4. Move existing spoke scaffolds from `spokes/<env>/<spoke-name>/kr/koreacentral/`
   to `stacks/<env>/kr/koreacentral/spokes/<spoke-name>/`.
5. Update validation commands, README paths, roadmap references, task history
   entries, and troubleshooting notes to the new paths.
6. Validate the moved dev hub stack with:

```bash
make fmt
make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network
```

7. Add staging and production hub scaffolds only as separate, reviewable tasks
   after the dev migration is clean.

## Rollback

Before any infrastructure apply, rollback is a code revert that restores the
previous directory contract. After any apply, rollback must be plan-reviewed per
environment because hub networking, private DNS links, routes, and firewall
resources can affect all spokes inside that environment.
