import { Button } from '@everdesk/ui/components/button'
import './App.css'
import { useState } from 'react'

function App() {
  const [count, setCount] = useState(0)
  const [count1, setCount1] = useState(0)

  return (
    <div className="h-full flex flex-col items-center justify-center gap-4">
      <h1>Client App</h1>
      <div className="flex flex-col gap-4">
        <Button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </Button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </div>
  )
}

export default App
