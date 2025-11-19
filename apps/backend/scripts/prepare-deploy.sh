#!/bin/bash
# Script to prepare Firebase Functions for deployment
# Packages workspace dependencies as .tgz files for npm compatibility

set -e

echo "📦 Building workspace dependencies..."
cd ../../packages/types && npm run build && cd -
echo "✅ Built @everdesk/types"

echo "🔨 Building backend..."
npm run build

echo "📦 Packing workspace dependencies..."
# Create a directory for packed dependencies
mkdir -p .packed-deps

# Pack the types package
cd ../../packages/types
TYPES_TARBALL=$(npm pack --quiet)
mv "$TYPES_TARBALL" ../../apps/backend/.packed-deps/
cd -
echo "✅ Packed @everdesk/types → .packed-deps/$TYPES_TARBALL"

echo "📝 Updating package.json with file: references..."
# Backup original package.json
cp package.json package.json.backup

# Update package.json to use packed .tgz files
node -e "
const fs = require('fs');
const path = require('path');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Find the packed tarball
const packedDir = '.packed-deps';
const files = fs.readdirSync(packedDir);
const typesTgz = files.find(f => f.startsWith('everdesk-types-'));

if (!typesTgz) {
  throw new Error('Could not find packed types tarball');
}

// Update dependencies to use file: protocol
if (pkg.dependencies && pkg.dependencies['@everdesk/types']) {
  pkg.dependencies['@everdesk/types'] = 'file:.packed-deps/' + typesTgz;
}

// Remove workspace devDependencies for deployment
if (pkg.devDependencies) {
  delete pkg.devDependencies['@everdesk/typescript-config'];
}

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('Updated @everdesk/types to:', pkg.dependencies['@everdesk/types']);
"
echo "✅ Updated package.json with file: references"

echo "🧹 Cleaning pnpm node_modules..."
rm -rf node_modules
echo "✅ Removed pnpm node_modules"

echo "🔧 Installing dependencies with npm..."
if [ ! -f "package-lock.json" ]; then
  echo "⚠️  No package-lock.json found - generating one..."
  echo "⚠️  You should commit this file to git for reproducible builds!"
  npm install --omit=dev --ignore-scripts
else
  echo "📦 Using existing package-lock.json (ensures consistent versions)"
  npm ci --omit=dev --ignore-scripts
fi
echo "✅ Dependencies installed"

echo "✨ Deploy preparation complete!"

