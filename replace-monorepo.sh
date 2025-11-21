#!/bin/bash

# Script to replace "monorepo" with a new name across src files and config files
# Usage: ./replace-monorepo.sh <new-name>

set -e

# Check if replacement string is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a replacement name"
    echo "Usage: $0 <new-name>"
    echo "Example: $0 my-project"
    exit 1
fi

NEW_NAME="$1"
OLD_NAME="monorepo"

echo "Replacing '$OLD_NAME' with '$NEW_NAME'..."
echo "This will modify files in src/ directories and config files (excluding .md files)"
echo ""

# Counter for modified files
count=0

# Function to replace text in a file
replace_in_file() {
    local file="$1"
    if grep -q "$OLD_NAME" "$file" 2>/dev/null; then
        # Use sed with backup (compatible with both GNU and BSD sed)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS (BSD sed)
            sed -i '' "s/$OLD_NAME/$NEW_NAME/g" "$file"
        else
            # Linux (GNU sed)
            sed -i "s/$OLD_NAME/$NEW_NAME/g" "$file"
        fi
        echo "  ✓ $file"
        ((count++))
    fi
}

export -f replace_in_file
export OLD_NAME NEW_NAME count

echo "Processing files..."
echo ""

# Find and replace in src directories (excluding .md files)
echo "→ Processing src/ directories..."
find . -type f -path "*/src/*" ! -name "*.md" ! -path "*/node_modules/*" ! -path "*/.git/*" | while read -r file; do
    replace_in_file "$file"
done

# Find and replace in linter config files
echo ""
echo "→ Processing linter config files..."
find . -type f \( \
    -name "eslint.config.js" -o \
    -name "eslint.config.mjs" -o \
    -name ".eslintrc" -o \
    -name ".eslintrc.js" -o \
    -name ".eslintrc.json" -o \
    -name ".eslintrc.yml" -o \
    -name ".eslintrc.yaml" \
\) ! -path "*/node_modules/*" ! -path "*/.git/*" | while read -r file; do
    replace_in_file "$file"
done

# Find and replace in tsconfig files
echo ""
echo "→ Processing tsconfig files..."
find . -type f \( \
    -name "tsconfig.json" -o \
    -name "tsconfig.*.json" \
\) ! -path "*/node_modules/*" ! -path "*/.git/*" | while read -r file; do
    replace_in_file "$file"
done

echo ""
echo "════════════════════════════════════════"
echo "✓ Replacement complete!"
echo "  Modified files: Check output above"
echo "════════════════════════════════════════"
echo ""
echo "Note: Review the changes with 'git diff' before committing"

