# Firebase Backend

Firebase Functions for the Everdesk monorepo.

## Quick Start

```bash
# From the monorepo root
pnpm install

# Build everything
cd apps/backend
npm run build

# Run locally
npm run serve

# Deploy to Firebase
npm run deploy
```

## Important Workflow: Adding Dependencies

⚠️ **CRITICAL**: After adding/updating dependencies with pnpm, you MUST sync the lockfile:

```bash
# 1. Add dependency with pnpm (for development)
pnpm add express

# 2. Immediately sync package-lock.json (for deployment)
npm run sync-lockfile

# 3. Commit both lockfiles
git add package.json package-lock.json ../../pnpm-lock.yaml
git commit -m "Add express dependency"
```

**Why?** 
- Dev uses pnpm → updates `pnpm-lock.yaml`
- Deploy uses npm → reads `package-lock.json`
- Without syncing, they'll have different versions! 💥

**Safety Net**: If you forget to sync, the deploy script will detect it and block deployment with a warning. Just run `npm run sync-lockfile` when prompted.

## Scripts

- `npm run build` - Compile TypeScript
- `npm run serve` - Run Firebase emulators locally
- `npm run deploy` - Deploy to Firebase (includes lockfile check, auto-handles everything)
- `npm run sync-lockfile` - ⚠️ **Run after adding/updating dependencies**
- `npm run check-lockfiles` - Check if lockfiles are in sync (runs automatically before deploy)
- `npm run prepare:deploy` - Prepare for deployment (don't run manually)
- `npm run postdeploy` - Clean up after deployment (don't run manually)

## Important Files

- `src/` - TypeScript source code
- `lib/` - Compiled JavaScript (git-ignored, but deployed to Firebase)
- `package.json` - Uses `workspace:*` for dev (pnpm)
- `package-lock.json` - ✅ **COMMITTED** - ensures reproducible Firebase builds
- `node_modules/@everdesk/` - Workspace packages from the monorepo
- `.firebaseignore` - Controls what gets deployed to Firebase
- `firebase.json` - Firebase configuration

## Deployment Notes

- Development uses **pnpm** with workspace symlinks
- Deployment uses **npm** with packed `.tgz` files
- The deploy script automatically switches between them
- Always commit `package-lock.json` for reproducible builds

## See Also

- [DEPLOYMENT.md](./DEPLOYMENT.md) - Detailed deployment guide
- [scripts/](./scripts/) - Deployment automation scripts

