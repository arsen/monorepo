import { Example } from "@monorepo/types";
import { ThemeToggle } from "@monorepo/ui/theme/ThemeToggle";

export default function Home() { 
  const example = Example.parse({
    id: "1",
    name: "Example",
    createdAt: new Date(),
  });
  console.log(example);
  return (
    <div className="flex flex-col gap-4 min-h-screen items-center justify-center">
      <h1 className="text-2xl font-bold">SSR Web App</h1>
      <ThemeToggle />
    </div>
  );
}
