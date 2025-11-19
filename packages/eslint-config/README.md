# `@monorepo/eslint-config`

Shared eslint configuration for the workspace.

## Available Configs

### For Vite React Apps

- `@monorepo/eslint-config/vite-react` - ESLint configuration for Vite-based React apps

### Usage in a Vite React App

**eslint.config.js:**
```javascript
import { config } from '@monorepo/eslint-config/vite-react'

export default config
```

### For Next.js Apps

- `@monorepo/eslint-config/nextjs` - ESLint configuration for Next.js apps

### Usage in a Next.js App

**eslint.config.mjs:**
```javascript
import { config } from '@monorepo/eslint-config/nextjs'

export default config
```

### Other Configs

- `base` - Base ESLint configuration
- `react-internal` - React internal configuration
