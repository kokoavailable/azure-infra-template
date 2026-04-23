SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

STACK ?=
MODULE ?=
PACKER_TEMPLATE ?=
PACKER_VARS ?=

.PHONY: help check-tools pre-commit-install fmt fmt-check validate validate-all \
        test docs docs-fmt plan apply destroy packer-fmt packer-validate packer-build \
        bootstrap-state bootstrap-state-dev bootstrap-state-stg bootstrap-state-prod

BOOTSTRAP_DIR := scripts/bootstrap
BOOTSTRAP_SCRIPT := $(BOOTSTRAP_DIR)/bootstrap-state-storage.sh
# dev | stg | prod — selects scripts/bootstrap/env/bootstrap-state.$(BOOTSTRAP_ENV).env
BOOTSTRAP_ENV ?= dev

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "; printf "\nTargets:\n\n"} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nVariables:\n\n"
	@printf "  STACK=<path>           e.g. platform/identity/02-identity-federation\n"
	@printf "  MODULE=<path>          e.g. modules/network\n"
	@printf "  PACKER_TEMPLATE=<file> e.g. packer/build-runtime-base.pkr.hcl\n"
	@printf "  PACKER_VARS=<file>     e.g. packer/dev.auto.pkrvars.hcl\n"
	@printf "  BOOTSTRAP_ENV=<name>   dev | stg | prod (make bootstrap-state)\n\n"

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

check-tools: ## Check required local binaries (Terraform 1.14.9 per versions.tf)
	@command -v terraform >/dev/null || { echo "terraform not found"; exit 1; }
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

# ---------- Plan / Apply / Destroy ----------

plan: ## Run terraform plan for a stack
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@cd $(STACK) && terraform init && terraform plan

apply: ## Run terraform apply for a stack
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@cd $(STACK) && terraform init && terraform apply

destroy: ## Run terraform destroy for a stack
	@test -n "$(STACK)" || { echo "STACK is required"; exit 1; }
	@cd $(STACK) && terraform init && terraform destroy

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