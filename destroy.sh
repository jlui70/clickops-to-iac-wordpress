#!/bin/bash

# =============================================================================
# Destroy Simplificado - Wrapper para o script principal
# =============================================================================

cd "$(dirname "$0")/terraform" || exit 1

echo "🗑️  Iniciando destruição da infraestrutura..."
echo ""

# Executar script de destroy
./scripts/destroy.sh

cd ..
