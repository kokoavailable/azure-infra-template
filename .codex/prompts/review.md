Read AGENTS.md first.

Review the current diff as a senior Azure/OpenTofu infrastructure reviewer.

Focus:
- state replacement risk
- backend changes
- provider changes
- provider lock changes
- remote-state direction
- RBAC scope creep
- secret leakage
- DNS/certificate impact
- missing variables
- missing outputs
- missing docs
- missing validation

Do not praise.

Output:
1. blocking issues
2. non-blocking issues
3. required fixes
4. verification commands
5. merge readiness