import { Example } from "@everdesk/types";
import { Button } from "@everdesk/ui/components/button";

export default function Home() { 
  const example = Example.parse({
    id: "1",
    name: "Example",
    createdAt: new Date(),
  });
  console.log(example);
  return (
    <div className="flex flex-col gap-4 min-h-screen items-center justify-center">
      <h1>Hello World</h1>
      <Button>Click me</Button>
    </div>
  );
}
