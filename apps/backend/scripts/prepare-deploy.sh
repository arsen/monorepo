#!/bin/bash
# Script to prepare Firebase Functions for deployment
# Prepares current folder with packed workspace dependencies

set -e

# ============================================================================
# CONFIGURATION: Add workspace dependencies here
# ============================================================================
# Format: "package-name:relative-path-from-backend"
WORKSPACE_DEPS=(
  "@everdesk/types:../../packages/types"
  # Add more workspace dependencies here, e.g.:
  # "@everdesk/ui:../../packages/ui"
  # "@everdesk/shared:../../packages/shared"
)
# ============================================================================

echo "🧹 Cleaning up old deployment artifacts..."
rm -rf .packed-deps
echo "✅ Removed old .packed-deps folder"

echo "📦 Building workspace dependencies..."
for dep in "${WORKSPACE_DEPS[@]}"; do
  IFS=':' read -r pkg_name pkg_path <<< "$dep"
  echo "   Building $pkg_name..."
  cd "$pkg_path" && npm run build && cd - > /dev/null
  echo "   ✅ Built $pkg_name"
done
echo "✅ All workspace dependencies built"

echo "🔨 Building backend..."
npm run build

echo "📁 Creating .packed-deps folder..."
mkdir -p .packed-deps

echo "📦 Packing workspace dependencies..."
# Store the backend directory path for later use
BACKEND_DIR="$(pwd)"
for dep in "${WORKSPACE_DEPS[@]}"; do
  IFS=':' read -r pkg_name pkg_path <<< "$dep"
  echo "   Packing $pkg_name..."
  cd "$pkg_path"
  TARBALL=$(npm pack --quiet)
  mv "$TARBALL" "$BACKEND_DIR/.packed-deps/"
  cd - > /dev/null
  echo "   ✅ Packed $pkg_name → .packed-deps/$TARBALL"
done
echo "✅ All workspace dependencies packed"

echo "📝 Backing up original package.json..."
cp package.json package.json.backup

echo "📝 Updating package.json with exact versions..."
# Update package.json with exact versions from pnpm
node -e "
const fs = require('fs');
const { execSync } = require('child_process');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Get exact versions from pnpm list
console.log('📋 Reading exact versions from pnpm...');
const pnpmList = execSync('pnpm list --json --depth=0', { encoding: 'utf8' });
const installed = JSON.parse(pnpmList)[0];

// Build a map of workspace package names to their tarball files
const packedDir = '.packed-deps';
const files = fs.readdirSync(packedDir);
const workspacePackageMap = {};

// Map tarball files to package names
// Tarball naming convention: scope-package-version.tgz (e.g., everdesk-types-1.0.0.tgz)
files.forEach(file => {
  if (file.endsWith('.tgz')) {
    // Extract package info from tarball filename
    // For @everdesk/types -> everdesk-types-x.y.z.tgz
    const match = file.match(/^(.+?)-(\d+\.\d+\.\d+.*?)\.tgz$/);
    if (match) {
      const [, nameSlug] = match;
      // Convert everdesk-types to @everdesk/types
      const scopedName = '@' + nameSlug.replace('-', '/');
      workspacePackageMap[scopedName] = file;
    }
  }
});

console.log('📦 Found workspace packages:', Object.keys(workspacePackageMap).join(', '));
console.log('📌 Pinning dependencies to exact versions:');

// Update dependencies with exact versions from pnpm
if (pkg.dependencies) {
  Object.keys(pkg.dependencies).forEach(name => {
    if (name.startsWith('@everdesk/')) {
      // Handle workspace packages with .tgz files
      if (workspacePackageMap[name]) {
        pkg.dependencies[name] = 'file:.packed-deps/' + workspacePackageMap[name];
        console.log('   ' + name + ': file:.packed-deps/' + workspacePackageMap[name]);
      } else {
        console.warn('⚠️  Warning: ' + name + ' not found in packed dependencies');
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

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('✅ Updated package.json with exact versions');
"

# echo "🔧 Installing dependencies..."
# npm install --omit=dev --ignore-scripts
# echo "✅ Installed production dependencies"

echo "✨ Deploy preparation complete!"
echo "📦 Ready to deploy with:"
echo "   ✓ package.json (with exact versions)"
echo "   ✓ lib/ (compiled code)"
echo "   ✓ .packed-deps/ (workspace dependencies)"
echo ""
echo "💡 Run 'firebase deploy --only functions' to deploy"
echo "💡 Run 'git restore package.json' after deployment to restore original package.json"