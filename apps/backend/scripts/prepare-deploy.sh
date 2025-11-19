#!/bin/bash
# Script to prepare Firebase Functions for deployment
# Bundles everything into .deploy folder with packed workspace dependencies

set -e

echo "🧹 Cleaning up old deployment bundle..."
rm -rf .deploy
echo "✅ Removed old .deploy folder"

echo "📦 Building workspace dependencies..."
cd ../../packages/types && npm run build && cd -
echo "✅ Built @everdesk/types"

echo "🔨 Building backend..."
npm run build

echo "📁 Creating .deploy folder structure..."
mkdir -p .deploy/.packed-deps

echo "📦 Packing workspace dependencies..."
# Pack the types package
cd ../../packages/types
TYPES_TARBALL=$(npm pack --quiet)
mv "$TYPES_TARBALL" ../../apps/backend/.deploy/.packed-deps/
cd -
echo "✅ Packed @everdesk/types → .deploy/.packed-deps/$TYPES_TARBALL"

echo "📋 Copying compiled code to .deploy..."
cp -r lib .deploy/
echo "✅ Copied lib/ to .deploy/lib/"

echo "📝 Creating deployment package.json with exact versions..."
# Create modified package.json with exact versions from pnpm
node -e "
const fs = require('fs');
const { execSync } = require('child_process');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Get exact versions from pnpm list
console.log('📋 Reading exact versions from pnpm...');
const pnpmList = execSync('pnpm list --json --depth=0', { encoding: 'utf8' });
const installed = JSON.parse(pnpmList)[0];

// Find the packed tarball
const packedDir = '.deploy/.packed-deps';
const files = fs.readdirSync(packedDir);
const typesTgz = files.find(f => f.startsWith('everdesk-types-'));

if (!typesTgz) {
  throw new Error('Could not find packed types tarball');
}

console.log('📌 Pinning dependencies to exact versions:');

// Update dependencies with exact versions from pnpm
if (pkg.dependencies) {
  Object.keys(pkg.dependencies).forEach(name => {
    if (name.startsWith('@everdesk/')) {
      // Handle workspace packages with .tgz files
      if (name === '@everdesk/types') {
        pkg.dependencies[name] = 'file:.packed-deps/' + typesTgz;
        console.log('   ' + name + ': file:.packed-deps/' + typesTgz);
      }
    } else {
      // Use exact version from pnpm for external packages
      if (installed.dependencies && installed.dependencies[name]) {
        const exactVersion = installed.dependencies[name].version;
        pkg.dependencies[name] = exactVersion; // Exact version, no ^
        console.log('   ' + name + ': ' + exactVersion);
      }
    }
  });
}

// Remove workspace devDependencies for deployment
if (pkg.devDependencies) {
  // Keep only non-workspace devDependencies (though they won't be installed)
  Object.keys(pkg.devDependencies).forEach(name => {
    if (name.startsWith('@everdesk/')) {
      delete pkg.devDependencies[name];
    }
  });
}

fs.writeFileSync('.deploy/package.json', JSON.stringify(pkg, null, 2));
console.log('✅ Created .deploy/package.json with exact versions');
"

# echo "🔧 Installing dependencies in .deploy folder..."
# cd .deploy
# npm install --omit=dev --ignore-scripts
# echo "✅ Installed production dependencies"
# cd ..

echo "✨ Deploy preparation complete!"
echo "📦 Everything bundled in .deploy/ folder:"
echo "   - .deploy/lib/                (compiled JavaScript)"
echo "   - .deploy/.packed-deps/       (workspace .tgz files)"
echo "   - .deploy/node_modules/       (npm dependencies)"
echo "   - .deploy/package.json        (with exact versions & file: references)"
echo "   - .deploy/package-lock.json   (for reproducibility)"
echo "   - .deploy/firebase.json       (Firebase configuration)"
echo "   - .deploy/*.rules             (Security rules)"

