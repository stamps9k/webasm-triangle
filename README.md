# webasm-triangle

A simple triangle drawn with WebGL 2 from Rust compiled to WebAssembly.

- `webasm/`: the Rust crate (`webasm-triangle`). It compiles the shaders and draws the triangle on the page's `glCanvas`.
- `website/`: the Vite site that loads the shaders and calls into the wasm package.

## Running locally

Requires Rust with the `wasm32-unknown-unknown` target, `wasm-pack` and Node.js. The dev container in `docker_files` has all of these.

```bash
cd webasm && wasm-pack build --target web
cd ../website && npm install && npm run dev
```

The site runs on port 1236. Build the wasm with `--target web`: the site loads it through the package's `init()` export, which the default bundler target doesn't have.

## Production

The `Dockerfile` builds the wasm package, builds the site with Vite and serves `website/dist` with nginx. The GitHub workflow publishes the image from the `deploy-latest` branch.

## Pre-commit hook

`website/.husky/pre-commit` (installed by `npm install` in `website/`) runs `cargo fmt --check`, `cargo clippy` for the wasm32 target and `cargo test` when `webasm/` changes, and a security audit (audit-ci or cargo-deny) when either half's dependency files change.
