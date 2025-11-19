# Firebase Backend Deployment

This Firebase Functions project is part of a pnpm monorepo but uses **npm for deployment** to ensure compatibility with Firebase Cloud Build.

## 📦 Bundled Deployment Strategy

All deployment artifacts are bundled into a **`.deploy/` folder** which is the only directory uploaded to Firebase:
- ✅ Self-contained deployment bundle
- ✅ All dependencies (including workspace `.tgz` files) packaged together  
- ✅ Clean separation between development and deployment
- ✅ Simplified `.firebaseignore` (only `.deploy/` is deployed)
- ✅ **Root environment never touched** - no backup/restore needed!

The root `package.json` and `node_modules` remain unchanged during deployment, so your development environment is never affected.

## Local Development

The backend uses **pnpm** with workspace dependencies during development:

```bash
# Install dependencies (from monorepo root)
pnpm install

# Build the types package (first time setup)
cd packages/types && pnpm run build && cd -

# Build backend TypeScript
npm run build

# Run emulators
npm run serve
```

### Development Workflow

When making changes to shared packages (like `@everdesk/types`):

1. Edit files in `/packages/types/src/`
2. Build the types package: `cd ../../packages/types && npm run build`
3. Backend will automatically pick up changes (via pnpm workspace symlink)
4. Rebuild backend: `npm run build`

Or use watch mode for types:
```bash
# Terminal 1: Watch types package
cd packages/types && npm run dev

# Terminal 2: Work on backend  
cd apps/backend && npm run build:watch
```

## Deployment to Firebase

### Standard Deployment

Use the deploy script which handles everything:

```bash
npm run deploy
```

This script automatically:
1. ✅ **Prepares**: Builds & packs workspace dependencies into `.deploy/` folder
2. ✅ **Deploys**: Uploads only `.deploy/` to Firebase

### What Happens Behind the Scenes

**During Deployment (`prepare:deploy`)**:
1. Cleans up any old `.deploy/` folder
2. Builds workspace packages (`@everdesk/types`) - compiles TypeScript → JavaScript
3. Builds the backend functions (outputs to `lib/` directory)
4. Creates `.deploy/` folder structure
5. **Packs workspace dependencies** using `npm pack` (creates `.tgz` files)
6. Copies compiled `lib/` directory into `.deploy/lib/`
7. Creates modified `package.json` in `.deploy/` with `file:` protocol references
8. Installs dependencies with npm inside `.deploy/node_modules/`
9. Copies `package-lock.json` to/from `.deploy/` for reproducibility

**What Gets Deployed** (everything is bundled in `.deploy/`):
- `.deploy/lib/` - Compiled JavaScript (from TypeScript build)
- `.deploy/.packed-deps/` - **Required!** Packed workspace dependencies (`.tgz` files)
- `.deploy/node_modules/` - Pre-installed dependencies (Firebase will also run `npm ci`)
- `.deploy/package.json` - Modified to use `file:` references (e.g., `file:.packed-deps/everdesk-types-0.0.0.tgz`)
- `.deploy/package-lock.json` - npm lockfile for reproducible builds

**Important**: Everything needed for deployment is self-contained in the `.deploy/` folder:
- `firebase.json` points to `.deploy` as the functions source
- `.firebaseignore` ensures only `.deploy/` is uploaded to Firebase
- All dependencies (including workspace `.tgz` files) are bundled inside
- Firebase Cloud Build runs `npm ci` inside `.deploy/` which has everything it needs

**What Doesn't Get Deployed** (via `.firebaseignore`):
- Everything at the root level (src/, scripts/, lib/, node_modules/, etc.)
- Only `.deploy/` folder is deployed
- `.git/`, logs, and other unnecessary files are excluded

**After Deployment**:
- The `.deploy/` folder remains (it's in `.gitignore`)
- Your root environment is **completely untouched**:
  - `package.json` still has `workspace:*` dependencies
  - `node_modules/` still has pnpm workspace symlinks
  - No restoration needed!
- The next `prepare:deploy` will clean up the old `.deploy/` automatically
- Optionally run `npm run cleanup` to remove `.deploy/` immediately

## Why This Approach?

**Problem**: Firebase Cloud Build uses npm, which doesn't understand pnpm's `workspace:` protocol.

**Solution**: 
- **Development**: Use pnpm with workspace symlinks (instant updates) ✅
- **Deployment**: Use npm with packed `.tgz` files (Firebase compatible) ✅
- **Auto-switch**: Scripts handle the transition automatically 🎉

**Benefits**:
- ✅ No manual intervention needed
- ✅ Firebase gets standard npm packages
- ✅ Development keeps fast workspace updates (root environment never touched!)
- ✅ Clean separation between dev and deploy (everything in `.deploy/`)
- ✅ Reproducible builds via committed `package-lock.json`
- ✅ No backup/restore needed - root `package.json` never modified

## Package Lock Management

### Why Commit `package-lock.json`?

**Without a lockfile** (dangerous ❌):
- `firebase-admin: ^12.6.0` could install `12.6.0`, `12.7.0`, or `12.8.0`
- Different deployments might get different versions
- Builds are **not reproducible**
- A working deploy today might break tomorrow

**With a committed lockfile** (safe ✅):
- Exact same versions installed every time
- Reproducible builds
- Predictable behavior

### How It Works

1. **First time**: `prepare:deploy` generates `package-lock.json` → **commit this to git**
2. **Subsequent times**: `prepare:deploy` uses existing lockfile with `npm ci`
3. **After adding dependencies**: Run `sync-lockfile` to update the lockfile

```bash
# After first prepare:deploy
git add package-lock.json
git commit -m "Add package-lock.json for reproducible Firebase builds"
```

### Critical: Sync After Adding Dependencies

⚠️ **IMPORTANT**: When you add/update dependencies with pnpm, you **MUST** sync the lockfile:

```bash
# 1. Add a new dependency using pnpm (in development)
pnpm add express
# → This updates pnpm-lock.yaml ✅
# → But NOT package-lock.json ❌

# 2. Immediately sync package-lock.json
npm run sync-lockfile
# → Regenerates package-lock.json with current versions ✅

# 3. Commit both lockfiles
git add package.json package-lock.json ../../pnpm-lock.yaml
git commit -m "Add express dependency"
```

**Why this matters:**
- Without syncing: Dev has `express@4.18.0`, but deployment might install `4.19.0` weeks later
- With syncing: Both dev and deployment use **exact same versions** ✅

### Safety Check: Automatic Detection

✅ **Don't worry if you forget!** The deploy script now has a built-in check:

```bash
# If you forget to sync and try to deploy:
npm run deploy

# Output:
⚠️  WARNING: package.json is newer than package-lock.json!
⚠️  You may have added dependencies without running sync-lockfile

Run this to sync:
  npm run sync-lockfile

# Deployment is BLOCKED until you sync! 🛡️
```

You can also manually check anytime:
```bash
npm run check-lockfiles
```

### The Workflow

```bash
# Adding a Firebase dependency
cd apps/backend
pnpm add @google-cloud/storage
npm run sync-lockfile
git add package.json package-lock.json ../../pnpm-lock.yaml
git commit -m "Add Google Cloud Storage"

# Updating an existing dependency  
pnpm add firebase-admin@latest
npm run sync-lockfile
git add package.json package-lock.json ../../pnpm-lock.yaml
git commit -m "Update firebase-admin"
```

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

2. Update `scripts/prepare-deploy.sh` to pack the new package:
```bash
# Pack the new package
cd ../../packages/your-package
YOUR_PKG_TARBALL=$(npm pack --quiet)
mv "$YOUR_PKG_TARBALL" ../../apps/backend/.deploy/.packed-deps/
cd -
echo "✅ Packed @everdesk/your-package → .deploy/.packed-deps/$YOUR_PKG_TARBALL"
```

3. Update the Node.js script in `prepare-deploy.sh` to handle the new package:
```javascript
const yourPkgTgz = files.find(f => f.startsWith('everdesk-your-package-'));
if (pkg.dependencies['@everdesk/your-package']) {
  pkg.dependencies['@everdesk/your-package'] = 'file:.packed-deps/' + yourPkgTgz;
}
```

Note: The path in `package.json` is still `file:.packed-deps/` (relative to `.deploy/` folder)

4. Run `pnpm install` from monorepo root

## Troubleshooting

### "Cannot find module '@everdesk/types'" during build

Make sure workspace dependencies are installed:
```bash
cd /path/to/monorepo/root
pnpm install
```

### "ENOENT: no such file or directory, open '.deploy/...'" or missing .deploy folder

The `.deploy/` folder was removed or doesn't exist yet. To build it:
```bash
npm run prepare:deploy
```

### Changes to workspace packages not reflected in development

This should never happen with the new bundled approach since your root environment is never modified! 

If you somehow have issues, reinstall with pnpm:
```bash
cd /path/to/monorepo/root
pnpm install
```

### Production has different versions than development

You added a dependency with pnpm but forgot to sync `package-lock.json`:
```bash
npm run sync-lockfile
git add package-lock.json
git commit -m "Sync package-lock.json"
```

### How do I know if lockfiles are out of sync?

Check the dependency versions:
```bash
# Check what dev has (from pnpm-lock.yaml)
pnpm list express

# Check what will deploy (from package-lock.json)
grep '"express":' package-lock.json -A2
```

If they differ, run `npm run sync-lockfile`.

### Manual Operations

**Prepare for deployment only** (without deploying):
```bash
npm run prepare:deploy
```

**Clean up .deploy folder** (optional - auto-cleaned on next prepare):
```bash
npm run cleanup
```

## Package Manager Status

| Environment | Package Manager | Dependencies Format | Location | Node Modules |
|-------------|----------------|---------------------|----------|--------------|
| Development | pnpm | `workspace:*` | Root | Symlinks to `/packages` |
| Deployment Prep | npm | `file:.packed-deps/*.tgz` | `.deploy/` | Real directories in `.deploy/node_modules/` |
| Firebase Cloud Build | npm | `file:.packed-deps/*.tgz` | `.deploy/` (on server) | Installed by npm ci |

The deployment scripts automatically switch between these environments and bundle everything into `.deploy/` for deployment!
