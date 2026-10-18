# --- WASM build stage ---------------------------------------------------
# Rust toolchain, cargo registry, and wasm-pack are all discarded after
# this stage - only the compiled wasm-bindgen package (pkg/) survives.
#
# Two different toolchains are needed here, for two different reasons:
#  - wasm-pack 0.15.0 (the build *tool*) pulls in clap 4.6.1, which needs
#    edition2024 - that requires cargo >= 1.85, so it has to be installed
#    with whatever recent toolchain this base image ships by default.
#  - the *crate* it compiles has to target Rust 1.81 or older: since Rust
#    1.82, wasm32-unknown-unknown enables the WebAssembly "reference types"
#    proposal by default, which the site's webpack 4 (via its bundled
#    @webassemblyjs parser) cannot parse - "Internal failure: parseVec
#    could not cast the value" in the type section. Toolchain modernization
#    (webpack 5) is out of scope here, so instead a second, older toolchain
#    is installed and targeted explicitly just for that step, via
#    RUSTUP_TOOLCHAIN, rather than changing the image's default toolchain.
#    See https://github.com/rustwasm/rust-webpack-template/issues/191
FROM rust:1-slim AS wasm-builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Installed from crates.io (checksum-verified by cargo) and pinned, rather
# than piping the rustwasm.github.io installer script straight to sh -
# reproducible, at the cost of compiling wasm-pack from source here.
RUN cargo install wasm-pack --locked --version 0.15.0

RUN rustup toolchain install 1.81.0 && \
    rustup target add wasm32-unknown-unknown --toolchain 1.81.0

WORKDIR /app/webasm
COPY webasm/Cargo.toml webasm/Cargo.lock ./
COPY webasm/src ./src
RUN RUSTUP_TOOLCHAIN=1.81.0 wasm-pack build

# --- Website build stage -------------------------------------------------
# Has webpack and all devDependencies. Discarded after this stage - none
# of it becomes part of the shipped image.
FROM node:22-slim AS website-builder
WORKDIR /app

# website/package.json depends on "wasm-game-of-life": "file:../webasm/pkg",
# so the wasm-pack output has to land at that sibling path before `npm ci`
# runs - npm needs the real files there to install the local dependency.
COPY --from=wasm-builder /app/webasm/pkg ./webasm/pkg
COPY website/package.json website/package-lock.json ./website/
WORKDIR /app/website
RUN npm ci --ignore-scripts

COPY website/. .
RUN npm run build

# --- Runtime stage ---------------------------------------------------
# No Rust, no Node - nginx just serves the files the previous stages
# already produced.
FROM nginx:alpine AS runtime
COPY --from=website-builder /app/website/dist /usr/share/nginx/html
