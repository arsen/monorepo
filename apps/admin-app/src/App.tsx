import './App.css'
import { ThemeToggle } from '@monorepo/ui/theme/ThemeToggle'

function App() {
  return (
    <div className="h-full flex flex-col items-center justify-center gap-4">
      <h1 className="text-2xl font-bold">Admin App</h1>
      <ThemeToggle />
    </div>
  )
}

export default App
