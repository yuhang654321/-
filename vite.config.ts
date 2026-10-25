import { defineConfig } from "vite";

export default defineConfig({
  server: {
    host: "127.0.0.1",
    port: 5173,
    watch: {
      ignored: ["**/models/**", "**/training/**", "**/demo/**", "**/.venv/**"],
    },
    proxy: {
      "/api": "http://127.0.0.1:8000",
    },
  },
  preview: {
    host: "127.0.0.1",
    port: 4173,
  },
  build: {
    target: "es2022",
    outDir: "dist",
    assetsDir: "static",
  },
});
