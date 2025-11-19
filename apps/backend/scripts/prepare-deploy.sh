#!/bin/bash
# Script to prepare Firebase Functions for deployment in a monorepo
# This ensures workspace dependencies are bundled for deployment

set -e

echo "🔨 Building TypeScript..."
pnpm run build

echo "📦 Copying workspace dependencies..."

# Create a temporary directory for workspace packages
mkdir -p node_modules/@everdesk

# Copy the types package (not symlink)
if [ -L "node_modules/@everdesk/types" ]; then
  rm node_modules/@everdesk/types
fi

# Copy from the actual workspace location
cp -r ../../packages/types node_modules/@everdesk/types
echo "✅ Copied @everdesk/types"

echo "✨ Deploy preparation complete!"

