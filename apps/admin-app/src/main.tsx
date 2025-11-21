import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import "@monorepo/ui/globals.css"
import App from './App.tsx'
import { ThemeProvider } from '@monorepo/ui/theme/ThemeProvider'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider>
    <App />
    </ThemeProvider>
  </StrictMode>,
)
