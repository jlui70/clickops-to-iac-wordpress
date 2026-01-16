#!/bin/bash

# =============================================================================
# Deploy Simplificado - Wrapper para o script principal
# =============================================================================

cd "$(dirname "$0")/terraform" || exit 1

echo "🚀 Iniciando deploy automatizado..."
echo ""

# Executar script de deploy
./scripts/deploy.sh

cd ..
