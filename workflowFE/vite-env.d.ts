/// <reference types="vite/client" />

interface ImportMetaEnv {
    readonly VITE_API_URL: string
    // Type definitions for other environment variables...
  }
  
  interface ImportMeta {
    readonly env: ImportMetaEnv
  }
