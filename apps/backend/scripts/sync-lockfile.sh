#!/bin/bash
# Script to sync package-lock.json with current pnpm lockfile
# This ensures npm uses the EXACT same versions that pnpm installed

set -e

echo "🔄 Syncing package-lock.json with pnpm-lock.yaml..."

# Backup original package.json
cp package.json package.json.backup

# Get exact versions from pnpm for all dependencies
echo "📋 Reading exact versions from pnpm..."
TEMP_PKG=$(mktemp)
node -e "
const fs = require('fs');
const { execSync } = require('child_process');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Get exact versions from pnpm list
const pnpmList = execSync('pnpm list --json --depth=0', { encoding: 'utf8' });
const installed = JSON.parse(pnpmList)[0];

console.log('Pinning versions to match pnpm:');

// Update dependencies with exact versions from pnpm
if (pkg.dependencies) {
  Object.keys(pkg.dependencies).forEach(name => {
    if (name.startsWith('@everdesk/')) {
      // Skip workspace packages for now
      return;
    }
    if (installed.dependencies && installed.dependencies[name]) {
      const exactVersion = installed.dependencies[name].version;
      console.log('  ' + name + ': ' + exactVersion);
      pkg.dependencies[name] = exactVersion; // Exact version, no ^
    }
  });
}

// Update devDependencies with exact versions from pnpm
if (pkg.devDependencies) {
  Object.keys(pkg.devDependencies).forEach(name => {
    if (name.startsWith('@everdesk/')) {
      // Skip workspace packages
      return;
    }
    if (installed.devDependencies && installed.devDependencies[name]) {
      const exactVersion = installed.devDependencies[name].version;
      console.log('  ' + name + ': ' + exactVersion);
      pkg.devDependencies[name] = exactVersion;
    }
  });
}

fs.writeFileSync('$TEMP_PKG', JSON.stringify(pkg, null, 2));
" 

# Use the pinned versions for creating package-lock.json
cp "$TEMP_PKG" package.json.pinned
rm "$TEMP_PKG"

# Build and pack workspace dependencies
echo "📦 Building and packing workspace dependencies..."
cd ../../packages/types && npm run build && cd -

mkdir -p .packed-deps
cd ../../packages/types
TYPES_TARBALL=$(npm pack --quiet)
mv "$TYPES_TARBALL" ../../apps/backend/.packed-deps/
cd -
echo "✅ Packed @everdesk/types"

# Update package.json to use file: references with PINNED versions
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json.pinned', 'utf8'));

const packedDir = '.packed-deps';
const files = fs.readdirSync(packedDir);
const typesTgz = files.find(f => f.startsWith('everdesk-types-'));

if (pkg.dependencies && pkg.dependencies['@everdesk/types']) {
  pkg.dependencies['@everdesk/types'] = 'file:.packed-deps/' + typesTgz;
}

if (pkg.devDependencies) {
  delete pkg.devDependencies['@everdesk/typescript-config'];
}

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

# Remove old package-lock.json to force regeneration with pinned versions
if [ -f "package-lock.json" ]; then
  echo "🗑️  Removing old package-lock.json"
  rm package-lock.json
fi

# Remove old node_modules
if [ -d "node_modules" ]; then
  echo "🗑️  Removing old node_modules"
  rm -rf node_modules
fi

# Generate fresh package-lock.json with EXACT versions from pnpm
echo "📝 Generating package-lock.json with exact versions from pnpm..."
npm install --omit=dev --ignore-scripts

# Restore original package.json (with ranges like ^4.18.0)
mv package.json.backup package.json
rm package.json.pinned

# Clean up
rm -rf .packed-deps
rm -rf node_modules

echo ""
echo "✅ package-lock.json has been updated!"
echo ""
echo "⚠️  IMPORTANT: Commit the updated package-lock.json:"
echo "   git add package-lock.json"
echo "   git commit -m 'Update package-lock.json after dependency changes'"
echo ""

