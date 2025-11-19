# `@monorepo/typescript-config`

Shared typescript configuration for the workspace.

## Available Configs

### For Vite React Apps

- `@monorepo/typescript-config/vite-react.json` - Main app TypeScript configuration
- `@monorepo/typescript-config/vite-node.json` - Node environment configuration (for vite.config.ts)

### Usage in a Vite React App

**tsconfig.app.json:**
```json
{
  "extends": "@monorepo/typescript-config/vite-react.json",
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
  "extends": "@monorepo/typescript-config/vite-node.json",
  "include": ["vite.config.ts"]
}
```

### For Next.js Apps

- `@monorepo/typescript-config/nextjs.json` - Next.js TypeScript configuration

### Usage in a Next.js App

**tsconfig.json:**
```json
{
  "extends": "@monorepo/typescript-config/nextjs.json",
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"]
}
```

### Other Configs

- `base.json` - Base configuration
- `react-library.json` - React library configuration
