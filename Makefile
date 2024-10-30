-include .env

.PHONY: build test deploy-local-tokens deploy-testnet-tokens deploy-local-treasury deploy-testnet-treasury deploy-all-local deploy-all-testnet clean install format

# Build all contracts
build:
	forge build

# Run all tests
test:
	forge test

# ========================
# Tokens Deployment
# ========================

# Deploy MANA Governance Token to local network (e.g., Anvil)
deploy-local-mana:
	@forge script script/DeployMANA.s.sol:DeployMANA --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy ManaToken to local network (e.g., Anvil)
deploy-local-manatoken:
	@forge script script/DeployManaToken.s.sol:DeployManaToken --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy FyreToken to local network (e.g., Anvil)
deploy-local-fyre:
	@forge script script/DeployFyreToken.s.sol:DeployFyreToken --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy all Tokens contracts locally in correct order
deploy-local-tokens: deploy-local-mana deploy-local-manatoken deploy-local-fyre

# Deploy MANA Governance Token to Aurora Testnet
deploy-testnet-mana:
	@forge script script/DeployMANA.s.sol:DeployMANA --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy ManaToken to Aurora Testnet
deploy-testnet-manatoken:
	@forge script script/DeployManaToken.s.sol:DeployManaToken --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy FyreToken to Aurora Testnet
deploy-testnet-fyre:
	@forge script script/DeployFyreToken.s.sol:DeployFyreToken --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy all Tokens contracts to Aurora Testnet in correct order
deploy-testnet-tokens: deploy-testnet-mana deploy-testnet-manatoken deploy-testnet-fyre

# ========================
# Treasury Deployment
# ========================

# Deploy PurchaseSHLDProxy to local network
deploy-local-shld-proxy:
	@forge script script/deploy_PurchaseSHLDProxy.sol:DeployPurchaseSHLDProxy --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy PurchaseMANA to local network
deploy-local-mana-treasury:
	@forge script script/deploy_PurchaseMANA.sol:DeployPurchaseMANA --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy PurchaseFYRE to local network
deploy-local-fyre-treasury:
	@forge script script/deploy_PurchaseFYRE.sol:DeployPurchaseFYRE --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy ManaBalanceVerifier to local network
deploy-local-mana-balance:
	@forge script script/deploy_ManaBalanceVerifier.sol:DeployManaBalanceVerifier --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy GenesisPriceOracle to local network
deploy-local-genesis-price-oracle:
	@forge script script/deploy_GenesisPriceOracle.sol:DeployGenesisPriceOracle --rpc-url http://127.0.0.1:8545 --broadcast --private-key $(LOCAL_PRIVATE_KEY) --legacy

# Deploy all Treasury contracts locally in the correct order
deploy-local-treasury: deploy-local-shld-proxy deploy-local-mana-treasury deploy-local-fyre-treasury deploy-local-mana-balance deploy-local-genesis-price-oracle

# Deploy PurchaseSHLDProxy to Aurora Testnet
deploy-testnet-shld-proxy:
	@forge script script/deploy_PurchaseSHLDProxy.sol:DeployPurchaseSHLDProxy --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy PurchaseMANA to Aurora Testnet
deploy-testnet-mana-treasury:
	@forge script script/deploy_PurchaseMANA.sol:DeployPurchaseMANA --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy PurchaseFYRE to Aurora Testnet
deploy-testnet-fyre-treasury:
	@forge script script/deploy_PurchaseFYRE.sol:DeployPurchaseFYRE --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy ManaBalanceVerifier to Aurora Testnet
deploy-testnet-mana-balance:
	@forge script script/deploy_ManaBalanceVerifier.sol:DeployManaBalanceVerifier --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy GenesisPriceOracle to Aurora Testnet
deploy-testnet-genesis-price-oracle:
	@forge script script/deploy_GenesisPriceOracle.sol:DeployGenesisPriceOracle --rpc-url $(AURORA_TESTNET_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --legacy

# Deploy all Treasury contracts to Aurora Testnet in the correct order
deploy-testnet-treasury: deploy-testnet-shld-proxy deploy-testnet-mana-treasury deploy-testnet-fyre-treasury deploy-testnet-mana-balance deploy-testnet-genesis-price-oracle

# ========================
# Combined Deployment
# ========================

# Deploy all contracts locally (Tokens and Treasury)
deploy-all-local: deploy-local-tokens deploy-local-treasury

# Deploy all contracts to Aurora Testnet (Tokens and Treasury)
deploy-all-testnet: deploy-testnet-tokens deploy-testnet-treasury

# Clean build artifacts
clean:
	forge clean

# Install dependencies
install:
	forge install foundry-rs/forge-std

# Format Solidity files
format:
	forge fmt
