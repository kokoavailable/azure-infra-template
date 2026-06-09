# Hub VNet Learning Notes

## Purpose

This note is for learning Azure hub networking at a portfolio and interview
level. The goal is not to memorize Azure resource names. The goal is to explain
network boundaries, state boundaries, dependency direction, operational risk,
and rollback thinking.

Repository examples in this note use the dev hub stacks:

```text
stacks/dev/kr/koreacentral/hub/
├── 00-hub-network
├── 05-private-dns
├── 10-egress-routing-security
└── 20-access-ops
```

## One-Sentence Definition

A hub stack is the shared network control plane for one environment.

It owns common network infrastructure such as the hub virtual network, shared
private DNS, egress routing intent, and operator access paths. Workload spokes
consume hub outputs downstream, but the hub should not depend on spoke state.

Interview version:

```text
The hub stack is the shared network control plane for an environment. I separate
hub network, private DNS, egress routing, and access operations into explicit
state boundaries so common infrastructure has a smaller review surface and
spokes can consume stable outputs without creating reverse dependencies.
```

## OpenTofu Syntax Foundation

### Resource Blocks

```hcl
resource "azurerm_virtual_network" "hub" {
  name                = local.vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_address_space

  tags = local.common_tags
}
```

How to read it:

```text
resource                     create or manage a real infrastructure object
azurerm_virtual_network      AzureRM provider resource type
hub                          local name inside this stack
var.*                        input from variables.tf / tfvars
local.*                      calculated value from locals.tf
azurerm_resource_group.*     reference to another managed resource
```

### Variables

Variables define the public input contract for a stack.

```hcl
variable "hub_address_space" {
  type        = list(string)
  description = "CIDR blocks assigned to the hub VNet."
}
```

Learning target:

- Know the difference between `string`, `list(string)`, `map(...)`, and
  `object(...)`.
- Use variable descriptions as operator-facing documentation.
- Put environment-specific values in `terraform.tfvars` or documented bootstrap
  inputs, not in resource blocks.

### Locals

Locals define calculated internal values.

```hcl
locals {
  resource_group_name = "${var.project_prefix}-${var.environment}-${var.region_code}-hub-rg"

  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "opentofu"
  })
}
```

Learning target:

- Use locals for derived names and normalized tags.
- Do not hide important operator decisions inside locals.
- Keep naming predictable enough that a reviewer can infer ownership.

### Outputs

Outputs are the downstream contract for other stacks.

```hcl
output "hub_vnet_id" {
  description = "Hub VNet ID for downstream spoke stacks."
  value       = azurerm_virtual_network.hub.id
}
```

Learning target:

- Output only values that downstream stacks need.
- Treat outputs as an API contract.
- Avoid exposing secrets or unnecessary resource internals.

### for_each

`for_each` creates one resource per key in a map or set.

```hcl
resource "azurerm_subnet" "hub" {
  for_each = var.hub_subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.address_prefixes
}
```

Example input shape:

```hcl
variable "hub_subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}
```

Learning target:

- Prefer stable keys such as `bastion`, `firewall`, or `shared-services`.
- Changing a `for_each` key can cause resource address changes.
- Review key changes carefully because they can imply replacement risk.

## Azure VNet Foundation

A virtual network is an isolated private network boundary in Azure. It has one
or more CIDR address spaces and can be segmented into subnets.

Core terms:

```text
VNet address space    The full CIDR allocation, such as 10.200.0.0/16.
Subnet                A smaller CIDR block inside the VNet, such as 10.200.1.0/24.
CIDR overlap          A routing conflict where two networks use the same address range.
Peering               Private connectivity between VNets over the Azure backbone.
DNS settings          VNet-level name resolution configuration.
```

What a senior reviewer checks:

- Does the hub CIDR overlap with spokes, other environments, or on-premises?
- Are reserved Azure subnets named and sized correctly?
- Is subnet purpose clear from the key and name?
- Are public entry points intentionally separated from private workloads?
- Are future peering and private endpoint needs considered?

Interview answer:

```text
I treat VNet CIDR as an architecture decision, not a code detail. If hub, spoke,
or on-premises address spaces overlap, peering and hybrid routing become
ambiguous. That can block connectivity or route traffic to the wrong place.
```

## Hub-Spoke Topology

Hub-spoke topology separates shared connectivity from workload isolation.

```text
hub
├── shared network services
├── private DNS
├── egress controls
├── firewall / NVA / gateway placement
└── operator access path

spoke/app-main
├── app subnets
├── private endpoint subnets
├── Key Vault / configuration / data
└── compute
```

The hub is not where application workloads should be scattered by default. It
exists to centralize shared network behavior and reduce duplicated control
planes.

Core rules:

- The hub should not depend on spoke state.
- Spokes may consume hub outputs downstream.
- Hub and spoke states should be separate.
- Shared network services belong in the hub.
- Workload lifecycle belongs in the spoke.

Bad dependency pattern:

```text
hub reads spoke output
spoke reads hub output
```

This creates cyclic dependency risk and unclear deployment order.

Good dependency pattern:

```text
hub/00-hub-network
  outputs hub_vnet_id, hub_subnet_ids

spokes/app-main/00-spoke-network
  reads hub outputs and creates spoke resources
```

## 00-hub-network

This stack should own the base hub resource group, hub VNet, and hub subnets.

Typical resources:

```text
azurerm_resource_group
azurerm_virtual_network
azurerm_subnet
```

Questions to answer before plan/apply:

- What is the hub CIDR?
- Which subnets are required now?
- Which subnets are reserved for future firewall, Bastion, gateway, or shared
  services?
- Which outputs must be consumed by private DNS, egress, access ops, or spokes?
- What is the rollback if the VNet or subnet layout is wrong?

Operational risks:

- CIDR overlap with future spokes or on-premises.
- Subnet too small for Azure service requirements.
- Subnet key rename causing replacement or state movement.
- Missing outputs that force downstream stacks to guess names.

Review checklist:

```text
state owner is one numbered stack
backend config remains externalized
CIDR is provided through tfvars or documented input
subnet map uses stable keys
outputs are minimal and useful
no dependency on spoke state
```

## 05-private-dns

This stack should own environment-level private DNS zones and links to VNets.

Typical resources:

```text
azurerm_private_dns_zone
azurerm_private_dns_zone_virtual_network_link
```

Private DNS matters because private endpoints use private IP addresses but
applications still use service names. DNS must resolve those names to the
private endpoint path.

Common private DNS zones:

```text
privatelink.vaultcore.azure.net
privatelink.postgres.database.azure.com
privatelink.blob.core.windows.net
privatelink.azconfig.io
```

Questions to answer before plan/apply:

- Which private endpoint services are in scope?
- Are zones centralized in the hub or owned per spoke?
- Which VNets get linked?
- Is registration enabled or disabled for each link?
- How will duplicate zones be avoided?

Operational risks:

- Duplicate private DNS zones causing inconsistent resolution.
- Missing VNet link causing private endpoint names to resolve publicly or fail.
- Wrong registration setting causing unexpected record behavior.
- DNS changes affecting multiple workloads at once.

Interview answer:

```text
I centralize private DNS in the hub when multiple spokes need consistent private
endpoint resolution. That reduces duplicate zones and DNS drift, but it also
makes DNS a high-blast-radius layer, so zone list and VNet links need explicit
review.
```

## 10-egress-routing-security

This stack should own route tables and the declared egress routing intent.

Typical resources:

```text
azurerm_route_table
route blocks inside the route table
future: route table associations, firewall policy, NAT or NVA integration
```

Azure creates system routes for every subnet. User-defined routes can override
some of that behavior.

Core terms:

```text
System route          Default Azure-managed route.
UDR                   User-defined route.
Route table           Collection of routes associated to subnet(s).
Default route         0.0.0.0/0 route for general outbound traffic.
Next hop              Where matching traffic is sent.
Effective routes      Actual route result after system, BGP, and UDR evaluation.
```

Questions to answer before plan/apply:

- Should internet-bound traffic go directly to Internet, NAT, firewall, or NVA?
- Are private endpoints affected?
- Are Azure service dependencies affected?
- Is BGP propagation enabled or disabled?
- Which subnets should receive the route table?

Operational risks:

- Breaking package downloads or update flows.
- Sending private endpoint traffic through the wrong path.
- Blackholing workload traffic with an incorrect next hop.
- Accidentally treating dev egress exceptions as production policy.

Interview answer:

```text
I treat default route changes as high risk because they can redirect all
outbound traffic for a subnet. Before applying them, I check next hop behavior,
private endpoint assumptions, Azure service dependencies, and effective routes.
```

## 20-access-ops

This stack should own operator access paths such as Azure Bastion.

Typical resources:

```text
azurerm_public_ip
azurerm_bastion_host
future: NSG/RBAC/access policy integration
```

Bastion allows operators to reach VMs without assigning public IPs to those VMs.
In hub-spoke designs, Bastion can be centralized in a hub VNet and used for
peered VNets when the network design supports it.

Questions to answer before plan/apply:

- Is Bastion needed in dev, stg, and prod?
- Is `AzureBastionSubnet` present and sized correctly?
- Which VNets are peered and reachable?
- What is the RBAC model for operator access?
- Is file copy enabled, and is that acceptable?

Operational risks:

- VM public IPs bypassing the intended private access model.
- Bastion cost in low-use environments.
- Access path assumptions differing between dev and prod.
- Too-broad operator access without RBAC review.

Interview answer:

```text
For production-style environments, I avoid public IPs on VMs and use a controlled
operator path such as Bastion, VPN, or ExpressRoute. Dev can have documented
cost-driven exceptions, but those exceptions should not silently promote to stg
or prod.
```

## State Boundary Thinking

This repository is a multi-stack repository. One stack owns one state.

Good state split:

```text
stacks/dev/kr/koreacentral/hub/00-hub-network.tfstate
stacks/dev/kr/koreacentral/hub/05-private-dns.tfstate
stacks/dev/kr/koreacentral/hub/10-egress-routing-security.tfstate
stacks/dev/kr/koreacentral/hub/20-access-ops.tfstate
stacks/dev/kr/koreacentral/spokes/app-main/00-spoke-network.tfstate
```

Why this matters:

- Smaller blast radius.
- Easier review.
- Clearer ownership.
- Safer rollback discussion.
- Fewer accidental shared-resource changes during workload edits.

Remote state rule:

```text
downstream stack may read upstream outputs
upstream stack must not read downstream outputs
```

Hub is upstream of spoke. Spoke is downstream of hub.

## Backend and tfvars Rules

Backend configuration should stay externalized through `backend.hcl` or
`backend.hcl.example`.

Do not commit:

```text
backend.hcl with real values
terraform.tfstate
terraform.tfstate.backup
*.tfplan
.env
real secrets
real tenant or subscription values
```

Preferred command interface:

```bash
make fmt
make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network
make plan STACK=stacks/dev/kr/koreacentral/hub/00-hub-network
```

Do not run raw `tofu apply` or `tofu destroy` unless explicitly approved.

## Senior-Level Review Questions

Use these questions after every hub stack change:

```text
What state owns this resource?
Could this change replace an existing resource?
Does this alter a backend or provider version?
Does any dependency point from hub to spoke?
Could this create a cyclic remote-state dependency?
Does this expand RBAC scope?
Does this expose a secret or backend value?
Could this alter DNS resolution for workloads?
Could this alter egress for multiple spokes?
Is the rollback a code revert, state move, or manual Azure recovery?
Was validation run through Makefile?
```

## Daily Practice Routine

Run this loop for each hub stack:

```text
1. Read README, variables.tf, main.tf, outputs.tf.
2. Write the stack responsibility in one sentence.
3. Identify upstream and downstream dependencies.
4. List resource replacement risks.
5. Run fmt/validate through Makefile.
6. Explain one failure or one risk in interview-answer form.
```

Example validation commands:

```bash
make fmt-check
make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network
make validate STACK=stacks/dev/kr/koreacentral/hub/05-private-dns
make validate STACK=stacks/dev/kr/koreacentral/hub/10-egress-routing-security
make validate STACK=stacks/dev/kr/koreacentral/hub/20-access-ops
```

## Interview Drills

### Why separate hub and spoke?

```text
Hub and spoke separate shared network control from workload lifecycle. The hub
owns common services such as DNS, routing, and operator access. Spokes own
workload-specific network and application resources. This keeps blast radius
smaller and prevents workload changes from accidentally changing shared network
foundations.
```

### Why separate hub stacks into multiple numbered layers?

```text
Different network layers have different risk profiles. Hub VNet, private DNS,
egress routing, and access operations can change independently and have
different rollback concerns. Separate state boundaries make review and
validation more targeted.
```

### Why should hub not depend on spoke?

```text
If hub depends on spoke and spoke depends on hub, deployment order becomes
cyclic and unclear. Hub should publish stable outputs, and downstream spokes
should consume them. That preserves the platform-to-workload dependency
direction.
```

### Why is DNS high risk?

```text
Private DNS affects service name resolution. A wrong zone, missing link, or
duplicate zone can make private endpoints unreachable or route clients to the
wrong endpoint. Because multiple workloads may depend on the same zone, DNS
changes need explicit review.
```

### Why is egress routing high risk?

```text
Route tables can redirect all outbound traffic for a subnet. A wrong default
route or next hop can break package downloads, service access, private endpoint
connectivity, or health checks. I review effective routes and service
dependencies before applying egress changes.
```

## Learning Sources

- Azure hub-spoke topology:
  <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology>
- Azure Virtual Network FAQ:
  <https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq>
- Azure virtual network traffic routing:
  <https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview>
- Azure Bastion with VNet peering:
  <https://learn.microsoft.com/en-us/azure/bastion/vnet-peering>
- Azure Private Link in hub-spoke networks:
  <https://learn.microsoft.com/en-us/azure/architecture/networking/guide/private-link-hub-spoke-network>
- OpenTofu variables and outputs:
  <https://opentofu.org/docs/language/values/>
- OpenTofu AzureRM backend:
  <https://opentofu.org/docs/language/settings/backends/azurerm/>
