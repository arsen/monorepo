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

### Other Configs

- `base` - Base ESLint configuration
- `next-js` - Next.js configuration
- `react-internal` - React internal configuration
