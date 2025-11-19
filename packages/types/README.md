# @everdesk/types

Shared types and Zod schemas for the Everdesk monorepo.

## Usage

Install the package in your app:

```json
{
  "dependencies": {
    "@everdesk/types": "workspace:*"
  }
}
```

## Importing

Import schemas and types in your apps:

```typescript
// Import Zod schemas
import { exampleSchema } from "@everdesk/types/schemas";

// Import TypeScript types
import type { ExampleType, Status } from "@everdesk/types/types";

// Or import everything
import { exampleSchema, type ExampleType } from "@everdesk/types/index";
```

## Structure

- `src/schemas/` - Zod validation schemas
- `src/types/` - TypeScript types and interfaces

## Adding New Types

1. Create a new file in `src/schemas/` for Zod schemas
2. Create a new file in `src/types/` for TypeScript types
3. Export them from the respective `index.ts` files

## Example

```typescript
// src/schemas/user.schema.ts
import { z } from "zod";

export const userSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string(),
});

export type User = z.infer<typeof userSchema>;
```

