# webasm-triangle (crate)

The Rust/WebAssembly half of [webasm-triangle](../README.md). It exports `initialize_web_gl(resources)`, which takes a `Map` with `vert_shader` and `frag_shader` source, compiles them and draws a triangle on the page's `<canvas id="glCanvas">` with WebGL 2.

```bash
wasm-pack build --target web   # outputs pkg/webasm_triangle.js for the website
cargo fmt --check
cargo clippy --target wasm32-unknown-unknown -- -D warnings
cargo test
```
