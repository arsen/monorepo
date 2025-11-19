# `@everdesk/typescript-config`

Shared typescript configuration for the workspace.

## Available Configs

### For Vite React Apps

- `@everdesk/typescript-config/vite-react.json` - Main app TypeScript configuration
- `@everdesk/typescript-config/vite-node.json` - Node environment configuration (for vite.config.ts)

### Usage in a Vite React App

**tsconfig.app.json:**
```json
{
  "extends": "@everdesk/typescript-config/vite-react.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
```

**tsconfig.node.json:**
```json
{
  "extends": "@everdesk/typescript-config/vite-node.json",
  "include": ["vite.config.ts"]
}
```

### Other Configs

- `base.json` - Base configuration
- `nextjs.json` - Next.js configuration
- `react-library.json` - React library configuration
