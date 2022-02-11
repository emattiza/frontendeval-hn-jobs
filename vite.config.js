import { defineConfig } from "vite";
import elmPlugin from "vite-plugin-elm";

export default defineConfig({
  root: "public",
  base: "/frontendeval-hn-jobs/",
  server: { hmr: { clientPort: 443 } },
  plugins: [elmPlugin()],
});
