# Firebase Backend Deployment

This Firebase Functions project is part of a pnpm monorepo and uses workspace dependencies.

## Local Development

```bash
# Install dependencies (from monorepo root)
pnpm install

# Build TypeScript
pnpm run build

# Run emulators
pnpm run serve
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
- Converts symlinks to real directories (Firebase can't upload symlinks)
- Copies `@everdesk/types` from `packages/types` → `node_modules/@everdesk/types`

**After Deployment (`restore:symlinks`)**:
- Removes hard copies of workspace packages
- Runs `pnpm install` to restore symlinks
- **This is crucial**: ensures changes to `packages/types` are immediately reflected in your backend during development

**Why this matters?** 
- With symlinks (dev): Changes to `packages/types` are instantly available ✅
- With hard copies (deploy): Firebase can upload the actual code ✅
- Auto-restore: You get the best of both worlds! 🎉

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

