#!/bin/bash
# Script to restore workspace symlinks after deployment
# This ensures development workflow continues to work with live updates

set -e

echo "🔗 Restoring workspace symlinks..."

# Remove the hard copy of types package
if [ -d "node_modules/@everdesk/types" ] && [ ! -L "node_modules/@everdesk/types" ]; then
  rm -rf node_modules/@everdesk/types
  echo "✅ Removed hard copy of @everdesk/types"
fi

# Restore original package.json if backup exists
if [ -f "package.json.backup" ]; then
  mv package.json.backup package.json
  echo "✅ Restored original package.json"
fi

# Restore symlinks by reinstalling from monorepo root
echo "📦 Reinstalling to restore symlinks..."
cd ../../ && pnpm install --prefer-offline && cd -

echo "✨ Symlinks restored! Development mode ready."

