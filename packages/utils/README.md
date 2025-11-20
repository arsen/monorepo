# @monorepo/utils

Shared utility functions for the monorepo.

## Usage

Install the package in your app:

```json
{
  "dependencies": {
    "@monorepo/utils": "workspace:*"
  }
}
```

## Importing

Import utility functions in your apps:

```typescript
import { exampleCamelCase } from "@monorepo/utils";

const result = exampleCamelCase("hello world"); // "helloWorld"
```

## Available Utilities

### `exampleCamelCase(str: string): string`

Converts a string to camelCase using lodash.

```typescript
import { exampleCamelCase } from "@monorepo/utils";

exampleCamelCase("hello world"); // "helloWorld"
exampleCamelCase("foo-bar-baz"); // "fooBarBaz"
```

## Adding New Utilities

1. Create or update files in `src/` with your utility functions
2. Export them from the `src/index.ts` file
3. Run `pnpm build` to compile TypeScript

## Development

```bash
# Build the package
pnpm build

# Watch mode for development
pnpm dev

# Type check
pnpm type-check

# Lint
pnpm lint
```