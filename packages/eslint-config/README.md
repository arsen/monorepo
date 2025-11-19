# `@everdesk/eslint-config`

Shared eslint configuration for the workspace.

## Available Configs

### For Vite React Apps

- `@everdesk/eslint-config/vite-react` - ESLint configuration for Vite-based React apps

### Usage in a Vite React App

**eslint.config.js:**
```javascript
import { config } from '@everdesk/eslint-config/vite-react'

export default config
```

### For Next.js Apps

- `@everdesk/eslint-config/nextjs` - ESLint configuration for Next.js apps

### Usage in a Next.js App

**eslint.config.mjs:**
```javascript
import { config } from '@everdesk/eslint-config/nextjs'

export default config
```

### Other Configs

- `base` - Base ESLint configuration
- `react-internal` - React internal configuration
