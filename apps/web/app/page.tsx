import { Button } from "@everdesk/ui/components/button"
import { useState } from "react"

export default function Page() {
  const [count1, setCount1] = useState(0);
  
  return (
    <div className="flex items-center justify-center min-h-svh">
      <div className="flex flex-col items-center justify-center gap-4">
        <h1 className="text-2xl font-bold">Hello World</h1>
        <Button size="sm">Button</Button>
      </div>
    </div>
  )
}
