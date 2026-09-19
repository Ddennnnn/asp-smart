import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import { fileURLToPath, URL } from 'node:url'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) } },
  build: { rolldownOptions: { output: { codeSplitting: { groups: [{ name: id => /node_modules[\\/](react|react-dom|scheduler)[\\/]/.test(id) ? 'react-runtime' : null }] } } } },
  server: { host: '127.0.0.1', proxy: { '/api': 'http://127.0.0.1:8000', '/sanctum': 'http://127.0.0.1:8000', '/storage': 'http://127.0.0.1:8000' } },
})
