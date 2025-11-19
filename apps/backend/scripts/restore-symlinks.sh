#!/bin/bash
# Script to clean up after deployment and restore development environment

set -e

echo "🧹 Cleaning up deployment artifacts..."

# Restore original package.json FIRST (before removing .packed-deps)
if [ -f "package.json.backup" ]; then
  mv package.json.backup package.json
  echo "✅ Restored original package.json"
fi

# Restore package-lock.json if it existed
if [ -f "package-lock.json.backup" ]; then
  mv package-lock.json.backup package-lock.json
  echo "✅ Restored package-lock.json"
elif [ -f "package-lock.json" ]; then
  rm package-lock.json
  echo "✅ Removed package-lock.json"
fi

# Reinstall with pnpm from monorepo root to restore workspace links
echo "📦 Reinstalling with pnpm..."
cd ../../ && pnpm install --prefer-offline && cd -

# NOW remove npm node_modules (after pnpm install succeeded)
if [ -d "node_modules" ]; then
  # Keep the pnpm structure, just ensure it's clean
  echo "✅ Node modules reinstalled with pnpm"
fi

# Remove packed dependencies (no longer needed)
if [ -d ".packed-deps" ]; then
  rm -rf .packed-deps
  echo "✅ Removed .packed-deps/"
fi

echo "✨ Development environment restored!"

