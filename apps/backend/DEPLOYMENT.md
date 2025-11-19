# Firebase Backend Deployment

This Firebase Functions project is part of a pnpm monorepo and uses workspace dependencies.

## Local Development

```bash
# Install dependencies (from monorepo root)
pnpm install

# Build the types package (first time setup)
cd packages/types && pnpm run build && cd -

# Build backend TypeScript
pnpm run build

# Run emulators
pnpm run serve
```

### Development Workflow

When making changes to shared packages (like `@everdesk/types`):

1. Edit files in `/packages/types/src/`
2. Build the types package: `cd ../../packages/types && pnpm run build`
3. Backend will automatically pick up changes (via symlink)
4. Rebuild backend: `pnpm run build`

Or use watch mode for types:
```bash
# Terminal 1: Watch types package
cd packages/types && pnpm run dev

# Terminal 2: Work on backend
cd apps/backend && pnpm run build:watch
```

## Deployment to Firebase

### Standard Deployment

Use the custom `deploy` script which handles workspace dependencies:

```bash
pnpm run deploy
```

This script automatically:
1. ✅ **Prepares**: Builds TypeScript & copies workspace packages (converts symlinks → hard copies)
2. ✅ **Deploys**: Uploads to Firebase
3. ✅ **Restores**: Converts hard copies back → symlinks (so development continues to work!)

### What Happens Behind the Scenes

**During Deployment (`prepare:deploy`)**:
1. Builds workspace packages (`@everdesk/types`) to compile TypeScript → JavaScript
2. Builds the backend functions (outputs to `lib/` directory)
3. Converts symlinks to real directories (Firebase can't upload symlinks)
4. Copies compiled packages from `packages/types` → `node_modules/@everdesk/types`
5. **Modifies `package.json`** - Removes `workspace:*` dependencies (Firebase uses npm, which doesn't understand pnpm workspace protocol)

**What Gets Deployed**:
- `lib/` - Compiled JavaScript (from TypeScript build)
- `node_modules/@everdesk/` - Workspace packages (hard copies)
- `package.json` - Modified to remove workspace dependencies
- Configuration files (firebase.json, etc.)

**What Doesn't Get Deployed** (via `.firebaseignore`):
- `src/` - Source TypeScript files (not needed, we have compiled JS)
- `scripts/` - Deployment scripts (not needed in production)
- `*.backup` - Backup files created during preparation
- Most of `node_modules/` (except workspace packages)
- `.git/`, logs, and other dev files

**After Deployment (`restore:symlinks`)**:
- Removes hard copies of workspace packages
- **Restores original `package.json`** with workspace dependencies
- Runs `pnpm install` to restore symlinks
- Cleans up temporary files (`package.json.backup`)
- **This is crucial**: ensures changes to `packages/types` are immediately reflected in your backend during development

**Why this matters?** 
- With symlinks (dev): Changes to `packages/types` are instantly available after rebuild ✅
- With hard copies (deploy): Firebase can upload the actual compiled code ✅
- Auto-restore: You get the best of both worlds! 🎉

**Module System**:
- `@everdesk/types` compiles to CommonJS (using `NodeNext`)
- Backend uses CommonJS (Firebase Functions standard)
- No experimental warnings or compatibility issues ✅

**Package Manager Compatibility**:
- Development uses pnpm with `workspace:*` protocol ✅
- Deployment creates npm-compatible `package.json` (removes workspace refs) ✅
- Firebase Cloud Build uses npm and installs only production dependencies ✅

## Adding More Workspace Dependencies

When you add a new workspace package:

1. Add to `package.json`:
```json
{
  "dependencies": {
    "@everdesk/your-package": "workspace:*"
  }
}
```

2. Update `scripts/prepare-deploy.sh` to copy the new package:
```bash
cp -r ../../packages/your-package node_modules/@everdesk/your-package
echo "✅ Copied @everdesk/your-package"
```

3. Run `pnpm install` from monorepo root

## Troubleshooting

### "Cannot find module '@everdesk/types'" in deployed functions

Run `pnpm run prepare:deploy` to ensure workspace packages are copied before deployment.

### Changes to workspace packages not reflected in development

If you accidentally have hard copies instead of symlinks:
```bash
pnpm run restore:symlinks
```

This will restore the symlinks so changes to `packages/types` are immediately available.

### Manual operations

**Prepare for deployment only** (without deploying):
```bash
pnpm run prepare:deploy
```

**Restore symlinks only** (if you forgot or deploy failed):
```bash
pnpm run restore:symlinks
```

