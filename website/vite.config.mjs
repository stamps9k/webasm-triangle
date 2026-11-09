import { defineConfig } from "vite";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));

// The site lives in www/ (two pages). Files fetched at runtime by URL
// (shaders, the teapot model) and robots.txt live in public/ and are
// copied to dist/ unchanged. The wasm package is built by wasm-pack into
// ../webasm/pkg and imported by relative path from www/js/index.js.
export default defineConfig({
  root: path.resolve(here, "www"),
  publicDir: path.resolve(here, "public"),
  // Relative asset URLs so the build works wherever nginx serves it.
  base: "./",
  server: {
    host: true,
    port: 1236,
    strictPort: true,
    // Allow the dev server to read the wasm package outside www/.
    fs: { allow: [path.resolve(here, "..")] },
  },
  build: {
    outDir: path.resolve(here, "dist"),
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: path.resolve(here, "www/index.html"),
        notes: path.resolve(here, "www/notes.html"),
      },
    },
  },
});
