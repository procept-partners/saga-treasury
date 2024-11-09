-include .env

.PHONY: help clean build deploy-all-local deploy-all-aurora deploy-fyre-local deploy-fyre-aurora deploy-mana-local deploy-mana-aurora deploy-manatoken-local deploy-manatoken-aurora deploy-treasury-local deploy-treasury-aurora transfer-ownership-local transfer-ownership-aurora

# Default Network Arguments for Local Deployment
LOCAL_NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(LOCAL_PRIVATE_KEY) --broadcast -vvvv

# Network Arguments for Aurora Testnet Deployment
AURORA_NETWORK_ARGS := --rpc-url $(AURORA_TESTNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv

help:
	@echo "Available commands for local and Aurora testnet deployment:"
	@echo "Local deployment:"
	@echo "  make deploy-all-local           Deploy all contracts and transfer ownership locally"
	@echo "  make deploy-fyre-local          Deploy FyreToken contract locally"
	@echo "  make deploy-mana-local          Deploy MANA contract locally"
	@echo "  make deploy-manatoken-local     Deploy ManaToken contract locally"
	@echo "  make deploy-treasury-local      Deploy Treasury contract locally"
	@echo "  make transfer-ownership-local   Transfer token ownership to Treasury locally"
	@echo ""
	@echo "Aurora testnet deployment:"
	@echo "  make deploy-all-aurora          Deploy all contracts and transfer ownership on Aurora testnet"
	@echo "  make deploy-fyre-aurora         Deploy FyreToken contract on Aurora testnet"
	@echo "  make deploy-mana-aurora         Deploy MANA contract on Aurora testnet"
	@echo "  make deploy-manatoken-aurora    Deploy ManaToken contract on Aurora testnet"
	@echo "  make deploy-treasury-aurora     Deploy Treasury contract on Aurora testnet"
	@echo "  make transfer-ownership-aurora  Transfer token ownership to Treasury on Aurora testnet"

# Clean and Build Commands
clean:; forge clean
build:; forge build

# Local Deployment Targets
deploy-fyre-local:
	@echo "Deploying FyreToken contract locally..."
	@forge script script/Tokens/FYRE/DeployFYREToken.s.sol $(LOCAL_NETWORK_ARGS)

deploy-mana-local:
	@echo "Deploying MANA governance token locally..."
	@forge script script/Tokens/MANA/DeployMANA.s.sol $(LOCAL_NETWORK_ARGS)

deploy-manatoken-local:
	@echo "Deploying ManaToken contract locally..."
	@forge script script/Tokens/MANA/DeploymanaToken.s.sol $(LOCAL_NETWORK_ARGS)

deploy-treasury-local:
	@echo "Deploying Treasury contract locally..."
	@forge script script/Treasury/DeployTreasury.s.sol $(LOCAL_NETWORK_ARGS)

transfer-ownership-local:
	@echo "Transferring ownership of tokens to Treasury locally..."
	@forge script script/Treasury/DeployOwner.s.sol $(LOCAL_NETWORK_ARGS)

deploy-all-local: deploy-fyre-local deploy-mana-local deploy-manatoken-local deploy-treasury-local transfer-ownership-local

# Aurora Testnet Deployment Targets
deploy-fyre-aurora:
	@echo "Deploying FyreToken contract on Aurora testnet..."
	@forge script script/Tokens/FYRE/DeployFYREToken.s.sol $(AURORA_NETWORK_ARGS)

deploy-mana-aurora:
	@echo "Deploying MANA governance token on Aurora testnet..."
	@forge script script/Tokens/MANA/DeployMANA.s.sol $(AURORA_NETWORK_ARGS)

deploy-manatoken-aurora:
	@echo "Deploying ManaToken contract on Aurora testnet..."
	@forge script script/Tokens/MANA/DeploymanaToken.s.sol $(AURORA_NETWORK_ARGS)

deploy-treasury-aurora:
	@echo "Deploying Treasury contract on Aurora testnet..."
	@forge script script/Treasury/DeployTreasury.s.sol $(AURORA_NETWORK_ARGS)

transfer-ownership-aurora:
	@echo "Transferring ownership of tokens to Treasury on Aurora testnet..."
	@forge script script/Treasury/DeployOwner.s.sol $(AURORA_NETWORK_ARGS)

deploy-all-aurora: deploy-fyre-aurora deploy-mana-aurora deploy-manatoken-aurora deploy-treasury-aurora transfer-ownership-aurora
