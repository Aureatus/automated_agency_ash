import { defineConfig } from "vite";
import path from "path";
import react from "@vitejs/plugin-react";
import { TanStackRouterVite } from "@tanstack/router-vite-plugin";

const suppressStartNotification = {
  name: "custom-startup-logger",
  configureServer(server) {
    server.printUrls = () => {
      console.log("\n\x1b[36m%s\x1b[0m", "🚀 Development server running!");
      console.log("\x1b[32m%s\x1b[0m", "➜ Access via: http://localhost");
      console.log("\x1b[90m%s\x1b[0m", "   Proxied by nginx\n");
    };
  },
};

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), TanStackRouterVite(), suppressStartNotification],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
