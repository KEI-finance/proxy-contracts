# Makefile for deploying to multiple chains and environments

# Environment variables
ENV ?= develop
CHAIN ?= sepolia

# Source .env file globally if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Decode secrets file if it exists
ifneq (,$(wildcard secrets/secrets.$(ENV).env))
    $(shell (sops -d secrets/secrets.$(ENV).env > .env.secrets) || (echo "Error decoding secrets file" >&2))
    -include .env.secrets
    export
    $(shell rm -f .env.secrets)
endif

# Phony targets
.PHONY: deploy deploy-resume typechain typechain-clean typechain-v5 typechain-v6 prepublish setup help test print-env

# Deploy to selected chain and environment
deploy:
	@echo "Deploying to $(CHAIN) in $(ENV) environment..."
	forge script script/Deploy.s.sol:DeployScript --broadcast --verify -vvvv --rpc-url $(CHAIN)
	$(MAKE) deploy-tag

# Resume deployment on selected chain and environment
deploy-resume:
	@echo "Resuming deployment on $(CHAIN) in $(ENV) environment..."
	forge script script/Deploy.s.sol:DeployScript --broadcast --verify --resume -vvvv --rpc-url $(CHAIN)
	$(MAKE) deploy-tag

deploy-tag:
	@echo "Tagging deployment to $(ENV) environment"
	forge-utils append-meta --meta.env $(ENV) --new-files
	git reset
	git add broadcast
	git commit -m "🚀🔥 DEPLOYED: $(CHAIN) network, $(ENV) environment 🌍💥"

# Clean TypeChain artifacts
typechain-clean:
	@echo "Cleaning TypeChain artifacts..."
	rm -rf typechain

# Generate TypeChain bindings for ethers-v6
typechain-v6:
	@echo "Generating TypeChain bindings for ethers-v6..."
	npx typechain --target ethers-v6 --out-dir typechain/ethers-v6 "./out/**/*.json" --show-stack-traces

# Generate TypeChain bindings for ethers-v5
typechain-v5:
	@echo "Generating TypeChain bindings for ethers-v5..."
	npx typechain --target ethers-v5 --out-dir typechain/ethers-v5 "./out/**/*.json" --show-stack-traces

clean-typechain-bytecode:
	@echo "Cleaning TypeChain bytecode..."
	forge-utils clean-typechain-bytecode

# Generate all TypeChain bindings
typechain: typechain-clean typechain-v6 typechain-v5 clean-typechain-bytecode

# Prepare for publishing
setup:
	@echo "Setting up the project..."
	pnpm install
	forge clean
	forge install
	forge build
	$(MAKE) typechain
	forge-utils deployments
	git add deployments.json

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	forge clean

# Run tests
test:
	@echo "Running tests..."
	forge test -vvv

# Print environment variables
print-env:
	@echo "Current environment variables:"
	@echo "ENV: $(ENV)"
	@echo "CHAIN: $(CHAIN)"

# Help target
help:
	@echo "Available targets:"
	@echo "  deploy         - Deploy contracts to selected chain and environment"
	@echo "  deploy-resume  - Resume deployment on selected chain and environment"
	@echo "  typechain      - Generate all TypeChain bindings"
	@echo "  typechain-clean - Clean TypeChain artifacts"
	@echo "  typechain-v5   - Generate TypeChain bindings for ethers-v5"
	@echo "  typechain-v6   - Generate TypeChain bindings for ethers-v6"
	@echo "  clean          - Clean build artifacts"
	@echo "  setup          - Setup the project"
	@echo "  test           - Run tests"
	@echo "  print-env      - Print current environment variables"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make [target] ENV=[develop|staging|production] CHAIN=[sepolia|mainnet|goerli]"
	@echo "  Example: make deploy ENV=staging CHAIN=sepolia"

# Default target
.DEFAULT_GOAL := setup
