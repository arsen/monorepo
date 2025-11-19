# @monorepo/types

Shared types and Zod schemas for the monorepo.

## Usage

Install the package in your app:

```json
{
  "dependencies": {
    "@monorepo/types": "workspace:*"
  }
}
```

## Importing

Import schemas and types in your apps:

```typescript
// Import Zod schemas
import { exampleSchema } from "@monorepo/types/schemas";

// Import TypeScript types
import type { ExampleType, Status } from "@monorepo/types/types";

// Or import everything
import { exampleSchema, type ExampleType } from "@monorepo/types/index";
```

## Adding New Types

1. Create a new file in `src/` for Zod schemas/types
2. Export them from the `index.ts` file

## Example

```typescript
// src/user.ts
import { z } from "zod";

export const User = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string().optional(),
});

export type User = z.infer<typeof User>;
```

