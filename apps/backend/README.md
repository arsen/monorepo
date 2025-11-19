# Firebase Backend

Firebase Functions for the Everdesk monorepo.

## Quick Start

```bash
# From the monorepo root
pnpm install

# Build everything
cd apps/backend
pnpm run build

# Run locally
pnpm run serve

# Deploy to Firebase
pnpm run deploy
```

## Important Files

- `src/` - TypeScript source code
- `lib/` - Compiled JavaScript (git-ignored, but deployed to Firebase)
- `node_modules/@everdesk/` - Workspace packages from the monorepo
- `.firebaseignore` - Controls what gets deployed to Firebase
- `firebase.json` - Firebase configuration

## Notes

- The `lib/` folder is in `.gitignore` but IS deployed to Firebase
- Workspace packages are automatically handled by the deploy script
- See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment information

