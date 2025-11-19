#!/bin/bash
# Script to check if lockfiles are potentially out of sync
# This helps catch cases where dependencies were added but sync-lockfile wasn't run

set -e

echo "🔍 Checking if lockfiles might be out of sync..."

# Check if package.json has been modified more recently than package-lock.json
if [ -f "package.json" ] && [ -f "package-lock.json" ]; then
  PACKAGE_JSON_TIME=$(stat -f %m package.json 2>/dev/null || stat -c %Y package.json 2>/dev/null)
  PACKAGE_LOCK_TIME=$(stat -f %m package-lock.json 2>/dev/null || stat -c %Y package-lock.json 2>/dev/null)
  
  if [ "$PACKAGE_JSON_TIME" -gt "$PACKAGE_LOCK_TIME" ]; then
    echo ""
    echo "⚠️  WARNING: package.json is newer than package-lock.json!"
    echo "⚠️  You may have added dependencies without running sync-lockfile"
    echo ""
    echo "Run this to sync:"
    echo "  npm run sync-lockfile"
    echo ""
    exit 1
  fi
fi

# Check if there are workspace dependencies
WORKSPACE_DEPS=$(grep -c "workspace:\*" package.json || echo "0")
if [ "$WORKSPACE_DEPS" -gt 0 ] && [ -f "package-lock.json" ]; then
  # Check if package-lock.json has file: references
  FILE_REFS=$(grep -c "file:.packed-deps" package-lock.json || echo "0")
  
  if [ "$FILE_REFS" -eq 0 ]; then
    echo ""
    echo "⚠️  WARNING: package.json has workspace:* dependencies"
    echo "⚠️  But package-lock.json doesn't have corresponding file: references"
    echo ""
    echo "This suggests the lockfile needs to be synced."
    echo "Run: npm run sync-lockfile"
    echo ""
    exit 1
  fi
fi

echo "✅ Lockfiles appear to be in sync"
exit 0

