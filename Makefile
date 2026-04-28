SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# Stack lifecycle targets use OpenTofu (`tofu`) and explicit -var-file injection (no symlink / no reliance on cwd auto-loading).
REPO_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null)
SHARED_VARS := $(REPO_ROOT)/platform/terraform.shared.tfvars

STACK ?=
MODULE ?=
PACKER_TEMPLATE ?=
PACKER_VARS ?=
# When set, plan/apply/destroy pass -backend-config=$(BACKEND_CONFIG). Empty = auto: use backend.hcl if that file exists in STACK.
BACKEND_CONFIG ?=

.PHONY: help check-tools pre-commit-install fmt fmt-check validate validate-all \
        test docs docs-fmt plan apply destroy plan-here apply-here destroy-here \
        packer-fmt packer-validate packer-build \
        bootstrap-state bootstrap-state-dev bootstrap-state-stg bootstrap-state-prod \
        bootstrap-state-teardown bootstrap-state-teardown-dev bootstrap-state-teardown-stg bootstrap-state-teardown-prod

BOOTSTRAP_DIR := scripts/bootstrap
BOOTSTRAP_SCRIPT := $(BOOTSTRAP_DIR)/bootstrap-state-storage.sh
BOOTSTRAP_TEARDOWN_SCRIPT := $(BOOTSTRAP_DIR)/bootstrap-state-teardown.sh
# dev | stg | prod — selects scripts/bootstrap/env/bootstrap-state.$(BOOTSTRAP_ENV).env
BOOTSTRAP_ENV ?= dev
# Set to 1 with make bootstrap-state-teardown to confirm RG deletion
BOOTSTRAP_TEARDOWN_YES ?=

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "; printf "\nTargets:\n\n"} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nVariables:\n\n"
	@printf "  STACK=<path>           e.g. platform/identity/02-identity-federation\n"
	@printf "  MODULE=<path>          e.g. modules/network\n"
	@printf "  PACKER_TEMPLATE=<file> e.g. packer/build-runtime-base.pkr.hcl\n"
	@printf "  PACKER_VARS=<file>     e.g. packer/dev.auto.pkrvars.hcl\n"
	@printf "  BOOTSTRAP_ENV=<name>   dev | stg | prod (bootstrap-state / teardown)\n"
	@printf "  BOOTSTRAP_TEARDOWN_YES=1  required for bootstrap-state-teardown-*\n"
	@printf "  BACKEND_CONFIG=<file>  optional; default backend.hcl if present in STACK\n"
	@printf "  plan|apply|destroy (tofu): require platform/terraform.shared.tfvars + stack terraform.tfvars\n"
	@printf "  plan-here|apply-here|destroy-here: run from stack dir; same var-files\n\n"

# ---------- Bootstrap (remote state storage) ----------

bootstrap-state: ## Create/update TF state blob storage using env/bootstrap-state.$(BOOTSTRAP_ENV).env
	@env_file="$(BOOTSTRAP_DIR)/env/bootstrap-state.$(BOOTSTRAP_ENV).env"; \
	if [ ! -f "$$env_file" ]; then \
	  echo "Missing: $$env_file"; \
	  echo "Copy $(BOOTSTRAP_DIR)/env/bootstrap-state.$(BOOTSTRAP_ENV).env.example -> $$env_file and edit names (storage account must be globally unique)."; \
	  exit 1; \
	fi
	@$(BOOTSTRAP_SCRIPT) --env-file "$(BOOTSTRAP_DIR)/env/bootstrap-state.$(BOOTSTRAP_ENV).env"

bootstrap-state-dev: ## Same as bootstrap-state with BOOTSTRAP_ENV=dev
	@$(MAKE) bootstrap-state BOOTSTRAP_ENV=dev

bootstrap-state-stg: ## Same as bootstrap-state with BOOTSTRAP_ENV=stg
	@$(MAKE) bootstrap-state BOOTSTRAP_ENV=stg

bootstrap-state-prod: ## Same as bootstrap-state with BOOTSTRAP_ENV=prod
	@$(MAKE) bootstrap-state BOOTSTRAP_ENV=prod

bootstrap-state-teardown: ## Delete bootstrap RG for env file (needs BOOTSTRAP_TEARDOWN_YES=1)
	@test "$(BOOTSTRAP_TEARDOWN_YES)" = "1" || { echo "Refusing: set BOOTSTRAP_TEARDOWN_YES=1 to delete resource group."; exit 1; }
	@env_file="$(BOOTSTRAP_DIR)/env/bootstrap-state.$(BOOTSTRAP_ENV).env"; \
	if [ ! -f "$$env_file" ]; then \
	  echo "Missing: $$env_file"; \
	  exit 1; \
	fi
	@$(BOOTSTRAP_TEARDOWN_SCRIPT) --env-file "$(BOOTSTRAP_DIR)/env/bootstrap-state.$(BOOTSTRAP_ENV).env" --yes

bootstrap-state-teardown-dev: ## Teardown bootstrap RG (dev); needs BOOTSTRAP_TEARDOWN_YES=1
	@$(MAKE) bootstrap-state-teardown BOOTSTRAP_ENV=dev

bootstrap-state-teardown-stg: ## Teardown bootstrap RG (stg); needs BOOTSTRAP_TEARDOWN_YES=1
	@$(MAKE) bootstrap-state-teardown BOOTSTRAP_ENV=stg

bootstrap-state-teardown-prod: ## Teardown bootstrap RG (prod); needs BOOTSTRAP_TEARDOWN_YES=1
	@$(MAKE) bootstrap-state-teardown BOOTSTRAP_ENV=prod

check-tools: ## Check required local binaries (OpenTofu for stack targets; Terraform fmt optional)
	@command -v tofu >/dev/null || { echo "tofu (OpenTofu) not found"; exit 1; }
	@command -v terraform >/dev/null || { echo "terraform not found (needed for fmt/validate targets)"; exit 1; }
	@command -v packer >/dev/null || { echo "packer not found"; exit 1; }
	@command -v pre-commit >/dev/null || { echo "pre-commit not found"; exit 1; }

pre-commit-install: ## Install git hooks locally
	@pre-commit install

# ---------- Format / Lint ----------

fmt: ## Format Terraform (.tf) and Packer files across the repo
	@terraform fmt -recursive
	@find packer -type f -name '*.pkr.hcl' -print0 2>/dev/null | xargs -0 -r packer fmt

fmt-check: ## Check Terraform formatting without writing (CI)
	@terraform fmt -check -recursive

docs-fmt: ## Format md/yaml/json with Prettier
	@npm exec -- prettier --write "**/*.{md,yml,yaml,json}" --ignore-path .gitignore

# ---------- Validate ----------

validate: ## Validate a single stack: make validate STACK=workloads/dev/...
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@cd $(STACK) && terraform init -backend=false -input=false && terraform validate

validate-all: ## Validate every directory that contains *.tf files
	@set -e; \
	dirs=$$(find . -name .git -prune -o -name node_modules -prune -o -name .terraform -prune -o -name '*.tf' -print \
	  | xargs -I {} dirname {} 2>/dev/null | sort -u); \
	if [ -z "$$dirs" ]; then echo "No .tf files found; skip"; exit 0; fi; \
	for d in $$dirs; do \
	  echo "==> $$d"; \
	  ( cd "$$d" && terraform init -backend=false -input=false >/dev/null && terraform validate ); \
	done

# ---------- Test ----------

test: ## Run terraform test for a module: make test MODULE=modules/network
	@test -n "$(MODULE)" || { echo "MODULE is required"; exit 1; }
	@cd $(MODULE) && terraform test

# ---------- Docs ----------

docs: ## Refresh terraform-docs via pre-commit
	@pre-commit run terraform_docs -a

# ---------- Plan / Apply / Destroy (OpenTofu; explicit var-files) ----------

plan: ## tofu plan: STACK=path from repo root; requires platform/terraform.shared.tfvars + stack terraform.tfvars
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@test -n "$(REPO_ROOT)" || { echo "git rev-parse failed — run inside the clone"; exit 1; }
	@test -d "$(REPO_ROOT)/$(STACK)" || { echo "No such directory: $(STACK)"; exit 1; }
	@test -f "$(SHARED_VARS)" || { echo "Missing $(SHARED_VARS) — copy platform/terraform.shared.tfvars.example"; exit 1; }
	@test -f "$(REPO_ROOT)/$(STACK)/terraform.tfvars" || { echo "Missing $(REPO_ROOT)/$(STACK)/terraform.tfvars"; exit 1; }
	@cd "$(REPO_ROOT)/$(STACK)" && bc="$(BACKEND_CONFIG)"; \
	  if [ -z "$$bc" ] && [ -f backend.hcl ]; then bc=backend.hcl; fi; \
	  if [ -n "$$bc" ]; then tofu init -backend-config="$$bc"; else tofu init; fi && \
	  tofu plan -var-file="$(SHARED_VARS)" -var-file=terraform.tfvars

apply: ## tofu apply (same inputs as plan)
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@test -n "$(REPO_ROOT)" || { echo "git rev-parse failed — run inside the clone"; exit 1; }
	@test -d "$(REPO_ROOT)/$(STACK)" || { echo "No such directory: $(STACK)"; exit 1; }
	@test -f "$(SHARED_VARS)" || { echo "Missing $(SHARED_VARS) — copy platform/terraform.shared.tfvars.example"; exit 1; }
	@test -f "$(REPO_ROOT)/$(STACK)/terraform.tfvars" || { echo "Missing $(REPO_ROOT)/$(STACK)/terraform.tfvars"; exit 1; }
	@cd "$(REPO_ROOT)/$(STACK)" && bc="$(BACKEND_CONFIG)"; \
	  if [ -z "$$bc" ] && [ -f backend.hcl ]; then bc=backend.hcl; fi; \
	  if [ -n "$$bc" ]; then tofu init -backend-config="$$bc"; else tofu init; fi && \
	  tofu apply -var-file="$(SHARED_VARS)" -var-file=terraform.tfvars

destroy: ## tofu destroy (same inputs as plan)
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@test -n "$(REPO_ROOT)" || { echo "git rev-parse failed — run inside the clone"; exit 1; }
	@test -d "$(REPO_ROOT)/$(STACK)" || { echo "No such directory: $(STACK)"; exit 1; }
	@test -f "$(SHARED_VARS)" || { echo "Missing $(SHARED_VARS) — copy platform/terraform.shared.tfvars.example"; exit 1; }
	@test -f "$(REPO_ROOT)/$(STACK)/terraform.tfvars" || { echo "Missing $(REPO_ROOT)/$(STACK)/terraform.tfvars"; exit 1; }
	@cd "$(REPO_ROOT)/$(STACK)" && bc="$(BACKEND_CONFIG)"; \
	  if [ -z "$$bc" ] && [ -f backend.hcl ]; then bc=backend.hcl; fi; \
	  if [ -n "$$bc" ]; then tofu init -backend-config="$$bc"; else tofu init; fi && \
	  tofu destroy -var-file="$(SHARED_VARS)" -var-file=terraform.tfvars

plan-here: ## tofu plan from current directory (must be a stack dir with terraform.tfvars)
	@test -n "$(REPO_ROOT)" || { echo "git rev-parse failed — run inside the clone"; exit 1; }
	@test -f "$(SHARED_VARS)" || { echo "Missing $(SHARED_VARS) — copy platform/terraform.shared.tfvars.example"; exit 1; }
	@test -f "$(CURDIR)/terraform.tfvars" || { echo "Missing $(CURDIR)/terraform.tfvars"; exit 1; }
	@cd "$(CURDIR)" && bc="$(BACKEND_CONFIG)"; \
	  if [ -z "$$bc" ] && [ -f backend.hcl ]; then bc=backend.hcl; fi; \
	  if [ -n "$$bc" ]; then tofu init -backend-config="$$bc"; else tofu init; fi && \
	  tofu plan -var-file="$(SHARED_VARS)" -var-file=terraform.tfvars

apply-here: ## tofu apply from current directory (same as plan-here)
	@test -n "$(REPO_ROOT)" || { echo "git rev-parse failed — run inside the clone"; exit 1; }
	@test -f "$(SHARED_VARS)" || { echo "Missing $(SHARED_VARS) — copy platform/terraform.shared.tfvars.example"; exit 1; }
	@test -f "$(CURDIR)/terraform.tfvars" || { echo "Missing $(CURDIR)/terraform.tfvars"; exit 1; }
	@cd "$(CURDIR)" && bc="$(BACKEND_CONFIG)"; \
	  if [ -z "$$bc" ] && [ -f backend.hcl ]; then bc=backend.hcl; fi; \
	  if [ -n "$$bc" ]; then tofu init -backend-config="$$bc"; else tofu init; fi && \
	  tofu apply -var-file="$(SHARED_VARS)" -var-file=terraform.tfvars

destroy-here: ## tofu destroy from current directory
	@test -n "$(REPO_ROOT)" || { echo "git rev-parse failed — run inside the clone"; exit 1; }
	@test -f "$(SHARED_VARS)" || { echo "Missing $(SHARED_VARS) — copy platform/terraform.shared.tfvars.example"; exit 1; }
	@test -f "$(CURDIR)/terraform.tfvars" || { echo "Missing $(CURDIR)/terraform.tfvars"; exit 1; }
	@cd "$(CURDIR)" && bc="$(BACKEND_CONFIG)"; \
	  if [ -z "$$bc" ] && [ -f backend.hcl ]; then bc=backend.hcl; fi; \
	  if [ -n "$$bc" ]; then tofu init -backend-config="$$bc"; else tofu init; fi && \
	  tofu destroy -var-file="$(SHARED_VARS)" -var-file=terraform.tfvars

# ---------- Packer ----------

packer-fmt: ## Format Packer templates
	@find packer -type f -name '*.pkr.hcl' -print0 2>/dev/null | xargs -0 -r packer fmt

packer-validate: ## Validate one Packer template
	@test -n "$(PACKER_TEMPLATE)" || { echo "PACKER_TEMPLATE is required"; exit 1; }
	@PACKER_VARS_ARG=""; \
	if [ -n "$(PACKER_VARS)" ]; then PACKER_VARS_ARG="-var-file=$(PACKER_VARS)"; fi; \
	packer init $(PACKER_TEMPLATE) && packer validate $$PACKER_VARS_ARG $(PACKER_TEMPLATE)

packer-build: ## Build one Packer template
	@test -n "$(PACKER_TEMPLATE)" || { echo "PACKER_TEMPLATE is required"; exit 1; }
	@PACKER_VARS_ARG=""; \
	if [ -n "$(PACKER_VARS)" ]; then PACKER_VARS_ARG="-var-file=$(PACKER_VARS)"; fi; \
	packer init $(PACKER_TEMPLATE) && packer build $$PACKER_VARS_ARG $(PACKER_TEMPLATE)