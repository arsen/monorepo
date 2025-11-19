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
4. Removes `package-lock.json`
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
