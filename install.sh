#!/bin/bash
# Install Foundry dependencies for this project.
# Requires: forge (https://book.getfoundry.sh/getting-started/installation)

set -e

echo "📦 Installing forge-std..."
forge install foundry-rs/forge-std --no-commit

echo "📦 Installing OpenZeppelin contracts..."
forge install OpenZeppelin/openzeppelin-contracts --no-commit

echo ""
echo "✅ Dependencies installed. You can now run:"
echo "   forge build"
echo "   forge test -vv"
