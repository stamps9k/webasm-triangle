# --- WASM build stage ---------------------------------------------------
# Rust toolchain, cargo registry, and wasm-pack are all discarded after
# this stage - only the compiled wasm-bindgen package (pkg/) survives.
#
# Built with `--target web`: the generated JS fetches and instantiates the
# .wasm itself, so the website bundler (Vite) only has to emit the file
# rather than parse it. That's what lets this use the image's current
# Rust toolchain - the old Rust 1.81 pin only existed because webpack 4
# couldn't parse wasm built by Rust 1.82+.
FROM rust:1-slim AS wasm-builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Installed from crates.io (checksum-verified by cargo) and pinned, rather
# than piping the rustwasm.github.io installer script straight to sh -
# reproducible, at the cost of compiling wasm-pack from source here.
RUN cargo install wasm-pack --locked --version 0.15.0

RUN rustup target add wasm32-unknown-unknown

WORKDIR /app/webasm
COPY webasm/Cargo.toml webasm/Cargo.lock ./
COPY webasm/src ./src
RUN wasm-pack build --target web

# --- Website build stage -------------------------------------------------
# Has Vite and all devDependencies. Discarded after this stage - none of
# it becomes part of the shipped image.
FROM node:22-slim AS website-builder
WORKDIR /app/website

COPY website/package.json website/package-lock.json ./
RUN npm ci --ignore-scripts

# www/js/index.js imports ../../../webasm/pkg, so the wasm-pack output
# goes at that sibling path.
COPY --from=wasm-builder /app/webasm/pkg /app/webasm/pkg
COPY website/. .
RUN npm run build

# --- Runtime stage ---------------------------------------------------
# No Rust, no Node - nginx just serves the files the previous stages
# already produced.
FROM nginx:alpine AS runtime
COPY --from=website-builder /app/website/dist /usr/share/nginx/html
