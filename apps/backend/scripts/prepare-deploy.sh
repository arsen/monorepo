#!/bin/bash
# Script to prepare Firebase Functions for deployment in a monorepo
# This ensures workspace dependencies are bundled for deployment

set -e

echo "📦 Building workspace dependencies..."
cd ../../packages/types && pnpm run build && cd -
echo "✅ Built @everdesk/types"

echo "🔨 Building backend..."
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

echo "📝 Creating deployment package.json..."
# Backup original package.json
cp package.json package.json.backup

# Remove workspace dependencies from package.json for deployment
# Firebase will use npm which doesn't understand workspace: protocol
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Remove workspace dependencies (we're copying them directly)
if (pkg.dependencies) {
  Object.keys(pkg.dependencies).forEach(key => {
    if (pkg.dependencies[key].startsWith('workspace:')) {
      delete pkg.dependencies[key];
    }
  });
}

if (pkg.devDependencies) {
  Object.keys(pkg.devDependencies).forEach(key => {
    if (pkg.devDependencies[key].startsWith('workspace:')) {
      delete pkg.devDependencies[key];
    }
  });
}

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"
echo "✅ Created deployment-ready package.json"

echo "✨ Deploy preparation complete!"

