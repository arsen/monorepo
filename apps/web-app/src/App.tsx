import { ThemeToggle } from '@monorepo/ui/theme/ThemeToggle'
import { Example } from '@monorepo/types'
import './App.css'

function App() {

  const example = Example.parse({
    id: "1",
    name: "Example",
    createdAt: new Date(),
  });
  console.log(example);
  return (
    <div className="h-full flex flex-col items-center justify-center gap-4">
      <h1 className="text-2xl font-bold">Web App</h1>
      <ThemeToggle />
    </div>
  )
}

export default App
