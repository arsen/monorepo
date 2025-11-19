# Firebase Backend Deployment

This Firebase Functions project is part of a pnpm monorepo but uses **npm for deployment** to ensure compatibility with Firebase Cloud Build.

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
1. ✅ **Prepares**: Builds & packs workspace dependencies, installs with npm
2. ✅ **Deploys**: Uploads to Firebase
3. ✅ **Restores**: Cleans up and restores pnpm workspace environment

### What Happens Behind the Scenes

**During Deployment (`prepare:deploy`)**:
1. Builds workspace packages (`@everdesk/types`) - compiles TypeScript → JavaScript
2. Builds the backend functions (outputs to `lib/` directory)
3. **Packs workspace dependencies** using `npm pack` (creates `.tgz` files)
4. Updates `package.json` to use `file:` protocol (points to `.tgz` files)
5. Removes pnpm `node_modules`
6. Installs dependencies with npm (Firebase compatible)

**What Gets Deployed**:
- `lib/` - Compiled JavaScript (from TypeScript build)
- `.packed-deps/` - **Required!** Packed workspace dependencies (`.tgz` files)
- `node_modules/` - Pre-installed dependencies (Firebase will also run `npm ci`)
- `package.json` - Modified to use `file:` references (e.g., `file:.packed-deps/everdesk-types-0.0.0.tgz`)
- `package-lock.json` - npm lockfile
- Configuration files (firebase.json, etc.)

**Important**: The `.packed-deps/` directory MUST be deployed because:
- `package.json` references the `.tgz` files inside it
- Firebase Cloud Build runs `npm ci` which needs to access these files
- Without it, the build will fail with "ENOENT: no such file or directory"

**What Doesn't Get Deployed** (via `.firebaseignore`):
- `src/` - Source TypeScript files (not needed, we have compiled JS)
- `scripts/` - Deployment scripts (not needed in production)
- `*.backup` - Backup files created during preparation
- `.git/`, logs, and other dev files

**After Deployment (`postdeploy`)**:
1. Restores original `package.json` with `workspace:*` dependencies
2. Reinstalls with pnpm to restore workspace symlinks
3. Removes `.packed-deps/` directory
4. **Keeps `package-lock.json`** (it should be committed to git for reproducible builds)
5. **This is crucial**: ensures changes to `packages/types` are immediately reflected in your backend during development

## Why This Approach?

**Problem**: Firebase Cloud Build uses npm, which doesn't understand pnpm's `workspace:` protocol.

**Solution**: 
- **Development**: Use pnpm with workspace symlinks (instant updates) ✅
- **Deployment**: Use npm with packed `.tgz` files (Firebase compatible) ✅
- **Auto-switch**: Scripts handle the transition automatically 🎉

**Benefits**:
- ✅ No manual intervention needed
- ✅ Firebase gets standard npm packages
- ✅ Development keeps fast workspace updates
- ✅ Clean separation between dev and deploy
- ✅ Reproducible builds via committed `package-lock.json`

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
mv "$YOUR_PKG_TARBALL" ../../apps/backend/.packed-deps/
cd -
echo "✅ Packed @everdesk/your-package → .packed-deps/$YOUR_PKG_TARBALL"
```

3. Update the Node.js script in `prepare-deploy.sh` to handle the new package:
```javascript
const yourPkgTgz = files.find(f => f.startsWith('everdesk-your-package-'));
if (pkg.dependencies['@everdesk/your-package']) {
  pkg.dependencies['@everdesk/your-package'] = 'file:.packed-deps/' + yourPkgTgz;
}
```

4. Run `pnpm install` from monorepo root

## Troubleshooting

### "Cannot find module '@everdesk/types'" during build

Make sure workspace dependencies are installed:
```bash
cd /path/to/monorepo/root
pnpm install
```

### "ENOENT: no such file or directory, open '.packed-deps/...'"

The `.packed-deps` directory was removed. This is normal after `postdeploy`. To rebuild:
```bash
npm run prepare:deploy
```

### Changes to workspace packages not reflected in development

If you accidentally have npm `node_modules` instead of pnpm workspace symlinks:
```bash
npm run postdeploy
```

This will restore the pnpm environment.

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

**Clean up after deployment** (restore dev environment):
```bash
npm run postdeploy
```

## Package Manager Status

| Environment | Package Manager | Dependencies Format | Node Modules |
|-------------|----------------|---------------------|--------------|
| Development | pnpm | `workspace:*` | Symlinks to `/packages` |
| Deployment | npm | `file:.packed-deps/*.tgz` | Real directories |
| Firebase Cloud Build | npm | `file:.packed-deps/*.tgz` | Installed by npm ci |

The deployment scripts automatically switch between these environments!
