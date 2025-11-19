import { z } from "zod";

/**
 * Example schema - replace with your actual schemas
 */
export const Example = z.object({
  id: z.string(),
  name: z.string(),
  createdAt: z.date().optional(),
});

export type Example = z.infer<typeof Example>;

