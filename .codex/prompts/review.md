Read `AGENTS.md` first.

If the target is under `platform/`, `spokes/`, or `stacks/`, also read the nearest scoped `AGENTS.md`.

Task:
Review the current diff as a senior Azure/OpenTofu infrastructure reviewer.

Focus:
- state replacement risk
- backend changes
- provider changes
- provider lock changes
- remote-state direction
- cyclic dependency risk
- RBAC scope creep
- secret leakage
- DNS and certificate impact
- missing variables
- missing outputs
- missing docs
- missing validation

Rules:
- Do not praise.
- Findings come first.
- Prefer concrete file references.
- Separate blocking from non-blocking issues.

Output:
1. blocking issues
2. non-blocking issues
3. required fixes
4. verification commands
5. merge readiness
